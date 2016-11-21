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

    fileprivate var input: PHContentEditingInput? {
        didSet {
            guard let inputData = input else { return }
            inputImage = inputData.displaySizeImage
            outputImage = inputImage // TODO: Need proceed inputImage instead.
        }
    }
    
    fileprivate var inputImage: NSImage? {
        didSet {
            inputImageView.image = inputImage
            outputImageView.image = outputImage
        }
    }
    
    fileprivate var outputImage: NSImage? {
        didSet { outputImageView.image = outputImage }
    }
    
    @IBOutlet weak var rightPanel: NSView!
    @IBOutlet weak var leftPanel: NSView!
    
    @IBOutlet weak var inputImageView: NSImageView!
    @IBOutlet weak var outputImageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        os_log("viewDidLoad()")
        
        inputImageView.translatesAutoresizingMaskIntoConstraints = false
        outputImageView.translatesAutoresizingMaskIntoConstraints = false
        
        leftRightSetup()
    }
    
    func leftRightSetup() {
        rightPanel.wantsLayer = true
        leftPanel.wantsLayer = true
        
        leftPanel.layer!.backgroundColor = NSColor(calibratedRed: 23.0/255, green: 23.0/255, blue: 23.0/255, alpha: 1.0).cgColor
        rightPanel.layer!.backgroundColor = NSColor(calibratedRed: 27.0/255, green: 27.0/255, blue: 27.0/255, alpha: 1.0).cgColor
    }

}

extension PhotoEditingViewController: PHContentEditingController {
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
        os_log("startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage)")
        input = contentEditingInput
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        os_log("finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void))")
        
        DispatchQueue.global().async {
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            // Provide new adjustments and render output to given location.
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        os_log("shouldShowCancelConfirmation: Bool")
        return false
    }
    
    func cancelContentEditing() {
        os_log("cancelContentEditing()")
    }
}

