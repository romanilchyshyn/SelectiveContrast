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
        let imageInPath = "/Users/romanilchyshyn/SelectiveContrastTests/in.png"
        let imageOutPath = "/Users/romanilchyshyn/SelectiveContrastTests/out.png"
        let imageInURL = URL(fileURLWithPath: imageInPath)
        
        guard let input = NSImage(contentsOf: imageInURL) else { fatalError("No input image") }
        let t1 = Date()
        let output = PiecewiseAffineHistogramEqualization.pae(with: input, sMin: 0.0, sMax: 3.0, N: 5)
        let t2 = Date()
        write(image: output, to: imageOutPath)
        
        let time = "PAE timing: t2 - t1 = \(t2.timeIntervalSince1970 - t1.timeIntervalSince1970) seconds."
        os_log("%@", time)

    }
    
}
