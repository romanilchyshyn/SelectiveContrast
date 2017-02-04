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

import SelectiveContrastKit

protocol PhotoEditingViewControllerDelegate: class {
    
    func plotDataDidUpdate(in outputContext: OutputContext)
    
}

class PhotoEditingViewController: NSViewController, EnhanceParametersViewControllerDelegate {

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
    
    fileprivate var outputContext: OutputContext? {
        didSet {
            guard let outCtx = outputContext else { return }
            outputImage = outCtx.image
        }
    }
    
    fileprivate var outputImage: NSImage? {
        didSet {
            inputOutputViewController.outputImage = outputImage
        }
    }
    
    weak var delegate: PhotoEditingViewControllerDelegate?
    
    private var tempSmin: Int?
    private var tempSmax: Int?
    private var tempN: Int?
    
    // MARK: IBOutlets
    @IBOutlet weak var contentPanel: NSView!
    @IBOutlet weak var parametersPanel: NSView!
    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad()", type: .info)
        
        contentPanel.addSubviewConstraintedToAnchors(inputOutputViewController.view)
        parametersPanel.addSubviewConstraintedToAnchors(parametersViewController.view)
        parametersViewController.delegate = self
        delegate = parametersViewController
    }
    
    // MARK: - EnhanceParametersViewControllerDelegate
    
    func parametersDidChange(smin: Int, smax: Int, N: Int) {
        tempSmin = smin
        tempSmax = smax
        tempN = N
        
        guard let inputImage = inputImage else { return }
        
        DispatchQueue.global().async {
            let t1 = Date()
            let out = PiecewiseAffineHistogramEqualization.pae(with: inputImage, sMin: Double(smin), sMax: Double(smax), N: N)
            let t2 = Date()
            let time = "PAE timing: t2 - t1 = \(t2.timeIntervalSince1970 - t1.timeIntervalSince1970) seconds."
            os_log("%@", time)
            
            DispatchQueue.main.async {
                self.outputContext = out
                self.delegate?.plotDataDidUpdate(in: out)
            }
        }
    }
    
    // MARK: - Helpers
    
    func processImage(to output: PHContentEditingOutput, completionHandler: ((PHContentEditingOutput?) -> Void)) {
        guard let input = contentEditingInput else { fatalError("missing input") }
        guard let url = input.fullSizeImageURL else { fatalError("missing input image url") }
        guard let inputImageCI = CIImage(contentsOf: url) else { fatalError("can't load input image to apply edit") }
        
        let orientedImageCI = inputImageCI.applyingOrientation(input.fullSizeImageOrientation)
        let orientedImageNS = NSImage(ciImage: orientedImageCI)
        
        guard let tempSmin = tempSmin, let tempSmax = tempSmax, let tempN = tempN else {
            completionHandler(nil)
            return
        }
        let outputImageNS = PiecewiseAffineHistogramEqualization.pae(with: orientedImageNS,
                                                                     sMin: Double(tempSmin),
                                                                     sMax: Double(tempSmax),
                                                                     N: tempN).image

        // MARK: Possible to do this with these lines
//        let pngData = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
//        let data = pngData.representation(using: .PNG, properties: [:])
//        data?.write(to: imageURL)
        
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

private extension CIImage {
    
    convenience init?(image: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        self.init(cgImage: cgImage)
    }
    
}
