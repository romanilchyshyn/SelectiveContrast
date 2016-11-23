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

class PhotoEditingViewController: NSViewController {

    // MARK: Properties
    let inputOutputViewController = PhotoInputOutputViewController()
    let parametersViewController = EnhanceParametersViewController()
    
    fileprivate var contentEditingInput: PHContentEditingInput? { didSet { inputImage = contentEditingInput?.displaySizeImage } }
    
    fileprivate var inputImage: NSImage? {
        didSet {
            inputOutputViewController.inputImage = inputImage
            inputOutputViewController.outputImage = inputImage // TODO: Need calculate output with default values.
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var contentPanel: NSView!
    @IBOutlet weak var parametersPanel: NSView!
    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad()", type: .info)
        
        contentPanel.addSubviewConstraintedToAnchors(inputOutputViewController.view)
        parametersPanel.addSubviewConstraintedToAnchors(parametersViewController.view)
        
        parametersViewController.enhance.asObservable().throttle(0.5, scheduler: MainScheduler.instance).subscribe { (wrapedEnhance) in
            print(wrapedEnhance.element)
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
            let output = PHContentEditingOutput(contentEditingInput: self.contentEditingInput!)
            
            // Provide new adjustments and render output to given location.
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
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

extension NSView {
    
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
