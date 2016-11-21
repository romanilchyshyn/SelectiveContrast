//
//  PhotoInputOutputViewController.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa

class PhotoInputOutputViewController: NSViewController {
    
    public var inputImage: NSImage? { didSet { inputImageView.image = inputImage } }
    public var outputImage: NSImage? { didSet { outputImageView.image = outputImage } }
    
    @IBOutlet weak var inputImageView: NSImageView!
    @IBOutlet weak var outputImageView: NSImageView!
    
}
