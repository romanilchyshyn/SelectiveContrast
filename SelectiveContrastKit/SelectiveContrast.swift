//
//  SelectiveContrast.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/23/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Foundation
import Accelerate
import os.log

public class SelectiveContrast {
    
    private static let log = OSLog(subsystem: "SelectiveContrastKit", category: "Image Processing")
    
    // MARK: NSImage
    
    public static func enhanceDark(_ inputImage: NSImage, t: Double, a: Double) -> NSImage {
        guard let inputImageCG = inputImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            os_log("Can't create CGImage from NSImage = %@", log: log, type: .error, inputImage.debugDescription)
            return NSImage()
        }
        var inputImageBuffer = inputImageCG.vImageBuffer
        defer { free(inputImageBuffer.data) }
        
        
        var outputImageBuffer = enhanceDark(&inputImageBuffer, format: inputImageCG.vImageFormat, t: t, a: a)
        defer { free(outputImageBuffer.data) }
        
        var grayImageFormat = vImage_CGImageFormat.planar8vImage_CGImageFormat()
        
        let outputImageCG = CGImage.cgImage(with: &outputImageBuffer, format: &grayImageFormat)
        
        return NSImage(cgImage: outputImageCG, size: NSZeroSize)
    }

    public static func enhanceGlobal(_ inputImage: NSImage, alpha: Double) -> NSImage {
        return NSImage()
    }
    
    // MARK: vImage_Buffer
    
    private static func enhanceDark(_ inputImage: inout vImage_Buffer, format: vImage_CGImageFormat, t: Double, a: Double) -> vImage_Buffer {
        return rgbaToGrayIntensity(input: &inputImage)
    }
    
    private static func enhanceGlobal(_ inputImage: inout vImage_Buffer, format: vImage_CGImageFormat, alpha: Double) -> vImage_Buffer {
        return rgbaToGrayIntensity(input: &inputImage)
    }
    
    
    private static func rgbaToGrayIntensity(input: inout vImage_Buffer) -> vImage_Buffer {
        var outBuffer = vImage_Buffer()
        let grayPixelBits = UInt32(8)
        vImageBuffer_Init(&outBuffer,
                          vImagePixelCount(input.height),
                          vImagePixelCount(input.width),
                          grayPixelBits,
                          vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        let divisor = Int32(UInt8.max)
        let red   = Int16(round(0.33 * Double(divisor)))
        let green = Int16(round(0.33 * Double(divisor)))
        let blue  = Int16(round(0.33 * Double(divisor)))
    
        let martix = [red, green, blue]
        
        vImageMatrixMultiply_ARGB8888ToPlanar8(&input,
                                               &outBuffer,
                                               martix,
                                               divisor,
                                               nil,
                                               divisor,
                                               vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        return outBuffer
    }

    
}

extension vImage_CGImageFormat {
    
    static func planar8vImage_CGImageFormat() -> vImage_CGImageFormat {
        return vImage_CGImageFormat(bitsPerComponent: 8,
                                    bitsPerPixel: 8,
                                    colorSpace: Unmanaged.passUnretained(CGColorSpaceCreateDeviceGray()),
                                    bitmapInfo: .alphaInfoMask,
                                    version: 0,
                                    decode: nil,
                                    renderingIntent: .defaultIntent)
    }
    
}
