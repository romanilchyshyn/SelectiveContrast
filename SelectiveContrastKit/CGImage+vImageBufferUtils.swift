//
//  CGImage+vImageBufferUtils.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/24/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Foundation
import Accelerate

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
