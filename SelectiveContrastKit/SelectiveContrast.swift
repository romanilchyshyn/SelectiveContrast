//
//  SelectiveContrast.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/23/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Foundation
import Accelerate

public class SelectiveContrast {
    
    public static func enhanceDark(_ inputImage: NSImage, t: Double, a: Double) -> NSImage {
        
        
        return NSImage()
    }

    public static func enhanceGlobal(_ inputImage: NSImage, alpha: Double) -> NSImage {
        
        let kernel = alpha * 100.0
        let k = UInt32(kernel)
        
        return convolveImageUsingAccelerate(image: inputImage, kernerSize: k)
    }
 
    
    static func convolveImageUsingAccelerate(image: NSImage, kernerSize: UInt32) -> NSImage {
        
        let inImageCG = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        
        var inBuffer: vImage_Buffer = inImageCG.vImageBuffer
        defer { free(inBuffer.data) }
        
        var format = inImageCG.vImageFormat
        
        var outBuffer: vImage_Buffer = vImage_Buffer.init()
        defer { free(outBuffer.data) }
        
        vImageBuffer_Init(&outBuffer, vImagePixelCount(inImageCG.height), vImagePixelCount(inImageCG.width), format.bitsPerPixel, vImage_Flags(kvImageNoFlags))
        
        vImageBoxConvolve_ARGB8888(&inBuffer,
                                   &outBuffer,
                                   nil,
                                   0,
                                   0,
                                   kernerSize,
                                   kernerSize,
                                   nil,
                                   vImage_Flags(kvImageCopyInPlace))
        
        let outImageCG: CGImage = vImageCreateCGImageFromBuffer(&outBuffer,
                                                                &format,
                                                                nil,
                                                                nil,
                                                                vImage_Flags(kvImageNoFlags),
                                                                nil).takeRetainedValue()
        
        let outputImage = NSImage.init(cgImage: outImageCG, size: NSZeroSize)
        
        return outputImage
    }
}


