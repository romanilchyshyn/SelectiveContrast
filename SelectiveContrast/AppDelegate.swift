//
//  AppDelegate.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 9/24/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa
import os.log

import SelectiveContrastKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func write(image: NSImage, to url: String) {
        let imageURL = URL(fileURLWithPath: url)
        let pngData = NSBitmapImageRep(cgImage: image.cgImage(forProposedRect: nil, context: nil, hints: nil)!)
        let data = pngData.representation(using: .PNG, properties: [:])
        
        do {
            try data?.write(to: imageURL)
        } catch let error {
            os_log("can't write image: %@", error.localizedDescription)
        }
    }

    
    func applicationDidFinishLaunching(_ notification: Notification) {
        
        let imageInPath = "/Users/romanilchyshyn/SelectiveContrastTests/image_in.png"
        let imageInURL = URL(fileURLWithPath: imageInPath)
        
        
        guard let inputImage = NSImage(contentsOf: imageInURL) else { fatalError("No input image") }
        
        
        var imageOut = SelectiveContrast.enhanceDark(inputImage, t: 0.0, a: 0.0)
        imageOut = SelectiveContrast.enhanceDark(inputImage, t: 0.0, a: 0.0)
        imageOut = SelectiveContrast.enhanceDark(inputImage, t: 0.0, a: 0.0)
        imageOut = SelectiveContrast.enhanceDark(inputImage, t: 0.0, a: 0.0)
        imageOut = SelectiveContrast.enhanceDark(inputImage, t: 0.0, a: 0.0)
        
        
        let imageOutPath = "/Users/romanilchyshyn/SelectiveContrastTests/image_out0.png"
        write(image: imageOut, to: imageOutPath)
        
    }
    
}
