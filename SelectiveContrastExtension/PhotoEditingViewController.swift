//
//  PhotoEditingViewController.swift
//  SelectiveContrastExtension
//
//  Created by Roman Ilchyshyn on 9/24/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa
import Photos
import PhotosUI

import os.log

import RxSwift

import SelectiveContrastKit

class PhotoEditingViewController: NSViewController {

    // MARK: Properties
    let inputOutputViewController = PhotoInputOutputViewController()
    let parametersViewController = EnhanceParametersViewController()
    
    fileprivate var contentEditingInput: PHContentEditingInput? { didSet { inputImage = contentEditingInput?.displaySizeImage } }
    
    fileprivate var inputImage: NSImage? {
        didSet {
            inputOutputViewController.inputImage = inputImage
            outputImage = inputImage
        }
    }
    
    fileprivate var outputImage: NSImage? {
        didSet {
            inputOutputViewController.outputImage = outputImage
        }
    }
    
    let disposeBag = DisposeBag()
    
    // MARK: IBOutlets
    @IBOutlet weak var contentPanel: NSView!
    @IBOutlet weak var parametersPanel: NSView!
    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad()", type: .info)
        
        contentPanel.addSubviewConstraintedToAnchors(inputOutputViewController.view)
        parametersPanel.addSubviewConstraintedToAnchors(parametersViewController.view)
        
        parametersViewController.enhance.asObservable()/*.throttle(0.5, scheduler: MainScheduler.instance)*/.subscribe { (wrapedEnhance) in
            print(wrapedEnhance.element ?? "")
            
            guard let inImage = self.inputImage else { return }
            guard let e = wrapedEnhance.element else { return }
            guard let alpha = e.alpha else { return }
            
            self.outputImage = SelectiveContrast.enhanceGlobal(inImage, alpha: alpha)
        } .addDisposableTo(disposeBag)
    }
    
    // MARK: Helpers
    
    func processImage(to output: PHContentEditingOutput, completionHandler: ((PHContentEditingOutput?) -> Void)) {
        guard let input = contentEditingInput else { fatalError("missing input") }
        guard let url = input.fullSizeImageURL else { fatalError("missing input image url") }
        guard let inputImageCI = CIImage(contentsOf: url) else { fatalError("can't load input image to apply edit") }
        
        let orientedImageCI = inputImageCI.applyingOrientation(input.fullSizeImageOrientation)
        let orientedImageNS = NSImage(ciImage: orientedImageCI)
        
        let outputImageNS: NSImage
        switch parametersViewController.enhance.value {
        case .Dark(let t, let a):
            outputImageNS = SelectiveContrast.enhanceDark(orientedImageNS, t: t, a: a)
        case .Global(let alpha):
            outputImageNS = SelectiveContrast.enhanceGlobal(orientedImageNS, alpha: alpha)
        }

        guard let outputImageCI = CIImage(image: outputImageNS) else { fatalError("can't create CIImage from NSImage") }
        
        let context = CIContext()
        do {
            output.adjustmentData = PHAdjustmentData(formatIdentifier: "id", formatVersion: "0", data: Data())
            try context.writeJPEGRepresentation(of: outputImageCI, to: output.renderedContentURL, colorSpace: inputImageCI.colorSpace!)
            completionHandler(output)
        } catch let error {
            os_log("can't write image: %@", error.localizedDescription)
            completionHandler(nil)
        }
    }
    
}

extension PhotoEditingViewController: PHContentEditingController {
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
        os_log("startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage)", type: .info)
        self.contentEditingInput = contentEditingInput
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        os_log("finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void))", type: .info)
        
        DispatchQueue.global().async {
            [unowned self] in
            if let editingInput = self.contentEditingInput {
                let output = PHContentEditingOutput(contentEditingInput: editingInput)
                
                self.processImage(to: output, completionHandler: completionHandler)
            }
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        os_log("shouldShowCancelConfirmation: Bool", type: .info)
        return false
    }
    
    func cancelContentEditing() {
        os_log("cancelContentEditing()", type: .info)
    }
}

private extension NSView {
    
    func addSubviewConstraintedToAnchors(_ view: NSView) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
}

private extension NSImage {
    convenience init(ciImage: CIImage) {
        self.init(size: ciImage.extent.size)
        self.addRepresentation(NSCIImageRep(ciImage: ciImage))
    }
}
