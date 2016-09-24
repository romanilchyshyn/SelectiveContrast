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

class PhotoEditingViewController: NSViewController, PHContentEditingController {

    var input: PHContentEditingInput?

    @IBOutlet weak var rightPanel: NSView!
    @IBOutlet weak var leftPanel: NSView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        leftRightSetup()
    }
    
    func leftRightSetup() {
        rightPanel.wantsLayer = true
        leftPanel.wantsLayer = true
        
        rightPanel.layer!.backgroundColor = NSColor.red.cgColor
        leftPanel.layer!.backgroundColor = NSColor.green.cgColor
    }

    // MARK: - PHContentEditingController

    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = <#new adjustment data#>
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }

    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }

    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }

}
