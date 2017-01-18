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
        
        var outputImageBuffer = vImage_Buffer()
        defer { free(outputImageBuffer.data) }
        
        enhanceDark(&inputImageBuffer, outputImage: &outputImageBuffer, t: t, a: a)
        
        var grayImageFormat = inputImageCG.vImageFormat
        let outputImageCG = CGImage.cgImage(with: &outputImageBuffer, format: &grayImageFormat)
        
        return NSImage(cgImage: outputImageCG, size: NSZeroSize)
    }

    public static func enhanceGlobal(_ inputImage: NSImage, alpha: Double) -> NSImage {
        return NSImage()
    }
    
    // MARK: vImage_Buffer
    
    private static func enhanceDark(_ inputImage: inout vImage_Buffer, outputImage: inout vImage_Buffer, t: Double, a: Double) {
        var grayImage = vImage_Buffer()
        defer { free(grayImage.data) }
        rgbaToGrayIntensity(rgbaInput: &inputImage, grayOutput: &grayImage)
        grayImage.printGrayFirstValues()

        var colorBalancedGrayImage = vImage_Buffer()
        defer { free(colorBalancedGrayImage.data) }
        simplestColorBalance(input: &grayImage, output: &colorBalancedGrayImage, s: UInt32(t / 5.0))
        colorBalancedGrayImage.printGrayFirstValues()
        
        var colorBalancedColoredImage = vImage_Buffer()
        print("start")
        inputImage.printRGBFirstValues()
        
        transformIntensities(rgbaImage: &inputImage,
                             grayImage: &grayImage,
                             grayEnhancedImage: &colorBalancedGrayImage,
                             rgbaOutputImage: &colorBalancedColoredImage)
        print("end")
        colorBalancedColoredImage.printRGBFirstValues()
        
        outputImage = colorBalancedColoredImage
    }
    
    private static func enhanceGlobal(_ inputImage: inout vImage_Buffer, output: inout vImage_Buffer, format: vImage_CGImageFormat, alpha: Double) {

    }
    
    // MARK: Utils
    
    private static func transformIntensities(rgbaImage: inout vImage_Buffer,
                                             grayImage: inout vImage_Buffer,
                                             grayEnhancedImage: inout vImage_Buffer,
                                             rgbaOutputImage: inout vImage_Buffer) {
        let rgbaBitsPerPixel = UInt32(32)
        
        vImageBuffer_Init(&rgbaOutputImage,
                          vImagePixelCount(rgbaImage.height),
                          vImagePixelCount(rgbaImage.width),
                          rgbaBitsPerPixel,
                          vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        for i in stride(from: 0, to: Int(rgbaImage.height), by: 1) {
            for j in stride(from: 0, to: Int(rgbaImage.width), by: 1) {
                let grayByteOffset = Int(grayImage.rowBytes) * i + j
                
                let grayIntensity = grayImage.data.load(fromByteOffset: grayByteOffset, as: UInt8.self)
                let grayEnhancedIntensity = grayEnhancedImage.data.load(fromByteOffset: grayByteOffset, as: UInt8.self)
                
                if grayIntensity == 0 || grayEnhancedIntensity == 0 {
                    continue
                }
                
                let A = Double(grayEnhancedIntensity) / Double(grayIntensity)
                
                let rgbaByteOffset = Int(rgbaImage.rowBytes) * i + j * 32 / 8
                let r = rgbaImage.data.load(fromByteOffset: rgbaByteOffset, as: UInt8.self)
                let g = rgbaImage.data.load(fromByteOffset: rgbaByteOffset + 1, as: UInt8.self)
                let b = rgbaImage.data.load(fromByteOffset: rgbaByteOffset + 2, as: UInt8.self)
                
                var re = Double(r) * A
                var ge = Double(g) * A
                var be = Double(b) * A
                
                if re > 255.0 || ge > 255.0 || be > 255.0 {
                    let B = Double(max(r, g, b))
                    let A1 = 255.0 / B

                    re = Double(r) * A1
                    ge = Double(g) * A1
                    be = Double(b) * A1
                }
                
                rgbaOutputImage.data.storeBytes(of: UInt8(Int(re)), toByteOffset: rgbaByteOffset, as: UInt8.self)
                rgbaOutputImage.data.storeBytes(of: UInt8(Int(ge)), toByteOffset: rgbaByteOffset + 1, as: UInt8.self)
                rgbaOutputImage.data.storeBytes(of: UInt8(Int(be)), toByteOffset: rgbaByteOffset + 2, as: UInt8.self)
            }
        }
    }
    
    private static func simplestColorBalance(input: inout vImage_Buffer, output: inout vImage_Buffer, s: UInt32) {
        let grayPixelBits = UInt32(8)
        vImageBuffer_Init(&output,
                          vImagePixelCount(input.height),
                          vImagePixelCount(input.width),
                          grayPixelBits,
                          vImage_Flags(kvImagePrintDiagnosticsToConsole))
        vImageEndsInContrastStretch_Planar8(&input,
                                            &output,
                                            s,
                                            s,
                                            vImage_Flags(kvImageDoNotTile))
    }
    
    private static func rgbaToGrayIntensity(rgbaInput: inout vImage_Buffer, grayOutput: inout vImage_Buffer) {
        // TODO: Need check that input is RGBA
        let grayPixelBits = UInt32(8)
        vImageBuffer_Init(&grayOutput,
                          vImagePixelCount(rgbaInput.height),
                          vImagePixelCount(rgbaInput.width),
                          grayPixelBits,
                          vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        let divisor = Int32(UInt8.max)
        let red   = Int16(round(0.33 * Double(divisor)))
        let green = Int16(round(0.33 * Double(divisor)))
        let blue  = Int16(round(0.33 * Double(divisor)))
    
        let martix = [red, green, blue]
        
        vImageMatrixMultiply_ARGB8888ToPlanar8(&rgbaInput,
                                               &grayOutput,
                                               martix,
                                               divisor,
                                               nil,
                                               divisor,
                                               vImage_Flags(kvImagePrintDiagnosticsToConsole))
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

private extension vImage_Buffer {
    
    func printGrayFirstValues() {
        print()
        for line in stride(from: 0, to: 10, by: 1) {
            print()
            for column in stride(from: 0, to: 10, by: 1) {
                let lineOffset = Int(self.rowBytes) * line
                let columnOffset = lineOffset + column

                let color = self.data.load(fromByteOffset: columnOffset, as: UInt8.self)
                print("\(color)", terminator: " ")
            }
        }
    }
    
    func printRGBFirstValues() {
        print()
        for i in stride(from: 0, to: 5, by: 1) {
            print()
            for j in stride(from: 0, to: 5, by: 1) {
                let rgbaByteOffset = Int(self.rowBytes) * i + j * 32 / 8
                let pixel = self.data.load(fromByteOffset: rgbaByteOffset, as: Pixel_8888.self)
                print("\(pixel)", terminator: " ")
            }
        }
    }
    
}
