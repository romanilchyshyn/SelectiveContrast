//
//  PiecewiseAffineHistogramEqualization.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 1/18/17.
//  Copyright © 2017 Roman Ilchyshyn. All rights reserved.
//

import Foundation
import Accelerate

public final class PAEInputContext {
    
    public let image: NSImage
    public let imageCG: CGImage
    public var imageBuffer: vImage_Buffer
    
    public var width: UInt { get { return imageBuffer.width } }
    public var height: UInt { get { return imageBuffer.height } }
    
    public var alphaBuffer = vImage_Buffer()
    public var redBuffer = vImage_Buffer()
    public var greenBuffer = vImage_Buffer()
    public var blueBuffer = vImage_Buffer()
    
    deinit {
        free(imageBuffer.data)
        free(alphaBuffer.data)
        free(redBuffer.data)
        free(greenBuffer.data)
        free(blueBuffer.data)
    }
    
    public init(image: NSImage) {
        self.image = image
        
        imageCG = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        imageBuffer = imageCG.vImageBuffer
        
        initARGBBuffers()
    }
    
    private func initARGBBuffers() {
        vImageBuffer_Init(&alphaBuffer, height, width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        vImageBuffer_Init(&redBuffer,   height, width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        vImageBuffer_Init(&greenBuffer, height, width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        vImageBuffer_Init(&blueBuffer,  height, width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        vImageConvert_ARGB8888toPlanar8(&imageBuffer,
                                        &redBuffer,
                                        &greenBuffer,
                                        &blueBuffer,
                                        &alphaBuffer,
                                        vImage_Flags(kvImagePrintDiagnosticsToConsole))
    }
    
    
}

public class PiecewiseAffineHistogramEqualization {
    
    public static func pae(with inputContext: PAEInputContext, sMin: Int, sMax: Int, N: Int) -> NSImage {
        
        
        var outRedBuffer = vImage_Buffer(data: inputContext.redBuffer.data,
                                         height: inputContext.height,
                                         width: inputContext.width,
                                         rowBytes: inputContext.redBuffer.rowBytes)
        defer { free(outRedBuffer.data) }
        
        var outGreenBuffer = vImage_Buffer(data: inputContext.greenBuffer.data,
                                           height: inputContext.height,
                                           width: inputContext.width,
                                           rowBytes: inputContext.greenBuffer.rowBytes)
        defer { free(outGreenBuffer.data) }
        
        var outBlueBuffer = vImage_Buffer(data: inputContext.blueBuffer.data,
                                          height: inputContext.height,
                                          width: inputContext.width,
                                          rowBytes: inputContext.blueBuffer.rowBytes)
        defer { free(outBlueBuffer.data) }
        
        
        PiecewiseAffineHistogramEqualization.makeBetter(inBuffer: inputContext.redBuffer, outBuffer: outRedBuffer)
        PiecewiseAffineHistogramEqualization.makeBetter(inBuffer: inputContext.greenBuffer, outBuffer: outGreenBuffer)
        PiecewiseAffineHistogramEqualization.makeBetter(inBuffer: inputContext.blueBuffer, outBuffer: outBlueBuffer)
        
        
        let rgbBitsPerPixel = UInt32(24)
        
        var outBuffer = vImage_Buffer()
        vImageBuffer_Init(&outBuffer, inputContext.height, inputContext.width, rgbBitsPerPixel, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        defer { free(outBuffer.data) }
        
        vImageConvert_Planar8toRGB888(&outRedBuffer,
                                      &outGreenBuffer,
                                      &outBlueBuffer,
                                      &outBuffer,
                                      vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        var rgbFormat = vImage_CGImageFormat(bitsPerComponent: 8,
                                             bitsPerPixel: rgbBitsPerPixel,
                                             colorSpace: Unmanaged.passUnretained(rgbColorSpace),
                                             bitmapInfo: .alphaInfoMask,
                                             version: 0,
                                             decode: nil,
                                             renderingIntent: .defaultIntent)
        let rgbCG = CGImage.cgImage(with: &outBuffer, format: &rgbFormat)
        
        return NSImage(cgImage: rgbCG, size: NSSize.zero)
    }
    
    private static func makeBetter(inBuffer: vImage_Buffer, outBuffer: vImage_Buffer) {
        
        for i in stride(from: 0, to: Int(inBuffer.height), by: 1) {
            for j in stride(from: 0, to: Int(inBuffer.width), by: 1) {
                let byteOffset = Int(inBuffer.rowBytes) * i + j
                
                let oldValue = inBuffer.data.load(fromByteOffset: byteOffset, as: UInt8.self)
                let intValue = Int(oldValue) + 42
                if intValue > 250 || intValue < 10 {
                    continue
                }
                
                let newValue = UInt8(intValue)
                outBuffer.data.storeBytes(of: newValue, toByteOffset: byteOffset, as: UInt8.self)
            }
        }
        
    }
    
}
