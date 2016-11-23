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
        var format = inImageCG.vImageFormat
        
        var outBuffer: vImage_Buffer = vImage_Buffer.init()
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
        
        free(inBuffer.data)
        
        let outImageCG: CGImage = vImageCreateCGImageFromBuffer(&outBuffer,
                                                                &format,
                                                                nil,
                                                                nil,
                                                                vImage_Flags(kvImageNoFlags),
                                                                nil).takeRetainedValue()
        
        free(outBuffer.data)
        
        let outputImage = NSImage.init(cgImage: outImageCG, size: NSZeroSize)
        
        return outputImage
    }
}

extension CGImage {
    
    // You are responsible for releasing the memory pointed to by buffer->data back to the system when you are done with it using free().
    var vImageBuffer: vImage_Buffer {
        var format = self.vImageFormat
        
        var imageBuffer = vImage_Buffer()
        vImageBuffer_InitWithCGImage(&imageBuffer,
                                     &format,
                                     nil,
                                     self,
                                     vImage_Flags(kvImagePrintDiagnosticsToConsole))
        return imageBuffer
    }
    
    var vImageFormat: vImage_CGImageFormat {
        return vImage_CGImageFormat.init(bitsPerComponent: UInt32(self.bitsPerComponent),
                                         bitsPerPixel: UInt32(self.bitsPerPixel),
                                         colorSpace: Unmanaged.passUnretained(self.colorSpace!),
                                         bitmapInfo: self.bitmapInfo,
                                         version: 0,
                                         decode: nil,
                                         renderingIntent: .defaultIntent)
    }
}
