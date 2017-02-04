//
//  PiecewiseAffineHistogramEqualization.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 1/18/17.
//  Copyright © 2017 Roman Ilchyshyn. All rights reserved.
//

import Foundation
import Accelerate

public struct OutputContext {
    
    public let image: NSImage
    public let ys: [Double]
    public let xs: (r: [Double], g: [Double], b: [Double])
    public let inHistogram: (r: [UInt], g: [UInt], b: [UInt])
    public let outHistogram: (r: [UInt], g: [UInt], b: [UInt])
    
}

public final class PiecewiseAffineHistogramEqualization {
    
    public static func pae(with inputImage: NSImage, sMin: Double, sMax: Double, N: Int) -> OutputContext {
        
        let inputCG = inputImage.cgImage(forProposedRect: nil, context: nil, hints: nil)!
        var inputBufferImage = inputCG.vImageBuffer
        defer { free(inputBufferImage.data) }
        
        var inAlphaBufferImage = vImage_Buffer()
        vImageBuffer_Init(&inAlphaBufferImage, inputBufferImage.height, inputBufferImage.width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        defer { free(inAlphaBufferImage.data) }
        
        var redBufferImage = vImage_Buffer()
        vImageBuffer_Init(&redBufferImage, inputBufferImage.height, inputBufferImage.width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        defer { free(redBufferImage.data) }
        
        var greenBufferImage = vImage_Buffer()
        vImageBuffer_Init(&greenBufferImage, inputBufferImage.height, inputBufferImage.width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        defer { free(greenBufferImage.data) }
        
        var blueBufferImage = vImage_Buffer()
        vImageBuffer_Init(&blueBufferImage, inputBufferImage.height, inputBufferImage.width, 8, vImage_Flags(kvImagePrintDiagnosticsToConsole))
        defer { free(blueBufferImage.data) }
        
        vImageConvert_ARGB8888toPlanar8(&inputBufferImage,
                                        &redBufferImage,
                                        &greenBufferImage,
                                        &blueBufferImage,
                                        &inAlphaBufferImage,
                                        vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        
        let Ys = ys(n: N)
        let Ys0to1 = ys0to1(ys: Ys)
        
        let (redInHistogram, redXs)     = processChannel(buffer: &redBufferImage, ys: Ys, ys0to1: Ys0to1, smin: sMin, smax: sMax)
        let (greenInHistogram, greenXs) = processChannel(buffer: &greenBufferImage, ys: Ys, ys0to1: Ys0to1, smin: sMin, smax: sMax)
        let (blueInHistogram, blueXs)   = processChannel(buffer: &blueBufferImage, ys: Ys, ys0to1: Ys0to1, smin: sMin, smax: sMax)
        
        let redOutHistogram     = histogram(bufferImage: &redBufferImage)
        let greenOutHistogram   = histogram(bufferImage: &greenBufferImage)
        let blueOutHistogram    = histogram(bufferImage: &blueBufferImage)
        
        var outputBuffer = vImage_Buffer()
        vImageBuffer_Init(&outputBuffer,
                          inputBufferImage.height,
                          inputBufferImage.width,
                          24,
                          vImage_Flags(kvImagePrintDiagnosticsToConsole))
        defer { free(outputBuffer.data) }
        
        vImageConvert_Planar8toRGB888(&redBufferImage,
                                      &greenBufferImage,
                                      &blueBufferImage,
                                      &outputBuffer,
                                      vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        var rgbFormat = vImage_CGImageFormat(bitsPerComponent: 8,
                                             bitsPerPixel: 24,
                                             colorSpace: Unmanaged.passUnretained(rgbColorSpace),
                                             bitmapInfo: .alphaInfoMask,
                                             version: 0,
                                             decode: nil,
                                             renderingIntent: .defaultIntent)
        
        let outputCG = CGImage.cgImage(with: &outputBuffer, format: &rgbFormat)
        let output = NSImage(cgImage: outputCG, size: NSSize.zero)

        return OutputContext(image: output,
                             ys: Ys,
                             xs: (redXs, greenXs, blueXs),
                             inHistogram: (redInHistogram, greenInHistogram, blueInHistogram),
                             outHistogram: (redOutHistogram, greenOutHistogram, blueOutHistogram))
    }

    private static func processChannel(buffer: inout vImage_Buffer,
                                       ys: [Double], ys0to1: [Double],
                                       smin: Double, smax: Double) -> (histogram: [UInt], xs: [Double]) {
        
        let hist = histogram(bufferImage: &buffer)
        let commulativeHist = cummulativeHistogram(histogram: hist)
        let Xs = xs(ys0to1: ys0to1, commulativeHistogram: commulativeHist)
        
        for i in stride(from: 0, to: Int(buffer.height), by: 1) {
            for j in stride(from: 0, to: Int(buffer.width), by: 1) {
                let byteOffset = Int(buffer.rowBytes) * i + j
                
                let oldValue = buffer.data.load(fromByteOffset: byteOffset, as: UInt8.self)
                let transformedValue = transform(x: Double(oldValue), xs: Xs, ys: ys, smin: smin, smax: smax)
                
                let transformedIntValue = Int(transformedValue)
                if transformedIntValue > Int(UInt8.max) || transformedIntValue < Int(UInt8.min) {
                    continue
                }
                
                let value = UInt8(transformedIntValue)
                buffer.data.storeBytes(of: value, toByteOffset: byteOffset, as: UInt8.self)
            }
        }

        return (hist, Xs)
    }
    
    // MARK: Histogram
    
    private static func histogram(bufferImage: inout vImage_Buffer) -> [UInt] {
        let count = 256
        let histogramBuffer = UnsafeMutablePointer<vImagePixelCount>.allocate(capacity: count)
        histogramBuffer.initialize(to: 0, count: count)
        defer {
            histogramBuffer.deinitialize(count: count)
            histogramBuffer.deallocate(capacity: count)
        }
        
        vImageHistogramCalculation_Planar8(&bufferImage,
                                           histogramBuffer,
                                           vImage_Flags(kvImagePrintDiagnosticsToConsole))
        
        let bufferPointer = UnsafeBufferPointer(start: histogramBuffer, count: count)
        return Array(bufferPointer)
    }
    
    private static func cummulativeHistogram(histogram: [UInt]) -> [Double] {
        var commulativeHistogram = [UInt]()
        var sum = UInt(0)
        for i in stride(from: 0, to: histogram.count, by: 1) {
            sum += histogram[i]
            commulativeHistogram.append(sum)
        }
        
        if commulativeHistogram.count == 0 {
            return [Double]()
        }
        
        let min = Double(commulativeHistogram.first!)
        let max = Double(commulativeHistogram.last!)
        
        return commulativeHistogram.map { (Double($0) - min) / (max - min) }
    }
    
    // MARK: Intervals
    
    private static func ys(n: Int) -> [Double] {
        var ys = [Double]()
        for k in stride(from: 0, to: n + 1, by: 1) {
            let y = Double(255) * Double(k) / Double(n)
            ys.append(y)
        }
        
        return ys
    }
    
    private static func ys0to1(ys: [Double]) -> [Double] {
        return ys.map { $0 / 255.0 }
    }
    
    private static func xs(ys0to1: [Double], commulativeHistogram: [Double]) -> [Double] {
        var xs = [Double]()
        
        for y in ys0to1 {
            for i in stride(from: 0, to: commulativeHistogram.count, by: 1) {
                let r = commulativeHistogram[i]
                if r > y { // We can do it by some quick find
                    let x = i - 1
                    xs.append(Double(x))
                    break
                }
                
                if i == commulativeHistogram.count - 1 {
                    xs.append(Double(i))
                }
            }
            
        }
        
        return xs
    }
    
    // MARK: Transform
    
    private static func transform(x: Double, xs: [Double], ys: [Double], smin: Double, smax: Double) -> Double {
        
        func mk(x0: Double, x1: Double, y0: Double, y1: Double, smin: Double, smax: Double) -> Double {
            let mk = (y1 - y0) / (x1 - x0)
            return mk < 1.0 ? max(mk, smin) : min(mk, smax)
        }
        
        func T(x: Double, x0: Double, y0: Double, m: Double) -> Double {
            return y0 + m * (x - x0)
        }
        
        for k in stride(from: 0, to: xs.count - 1, by: 1) { // We can do it faster
            let xk = xs[k]
            let xk1 = xs[k+1]
            
            let yk = ys[k]
            let yk1 = ys[k+1]
            
            if xk < x && x <= xk1 {
                let m = mk(x0: xk, x1: xk1, y0: yk, y1: yk1, smin: smin, smax: smax)
                return T(x: x, x0: xk, y0: yk, m: m)
            }
            
        }
        
        return x
    }

}
