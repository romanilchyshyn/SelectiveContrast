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

class PhotoEditingViewController: NSViewController {

    // MARK: Properties
    let inputOutputViewController = PhotoInputOutputViewController()
    
    fileprivate var contentEditingInput: PHContentEditingInput? { didSet { inputImage = contentEditingInput?.displaySizeImage } }
    
    fileprivate var inputImage: NSImage? {
        didSet {
            inputOutputViewController.inputImage = inputImage
            inputOutputViewController.outputImage = inputImage // TODO: Need calculate output with default values.
        }
    }
    
    // MARK: IBOutlets
    @IBOutlet weak var rightPanel: NSView!
    @IBOutlet weak var leftPanel: NSView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad()", type: .info)
        
        addInputOutputViewController()
    }
    
    func addInputOutputViewController() {
        leftPanel.addSubview(inputOutputViewController.view)
        inputOutputViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftPanel.topAnchor.constraint(equalTo: inputOutputViewController.view.topAnchor),
            leftPanel.bottomAnchor.constraint(equalTo: inputOutputViewController.view.bottomAnchor),
            leftPanel.leadingAnchor.constraint(equalTo: inputOutputViewController.view.leadingAnchor),
            leftPanel.trailingAnchor.constraint(equalTo: inputOutputViewController.view.trailingAnchor)
        ])
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

