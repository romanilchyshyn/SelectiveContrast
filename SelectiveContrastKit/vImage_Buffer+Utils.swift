//
//  vImage_Buffer+Utils.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 1/19/17.
//  Copyright © 2017 Roman Ilchyshyn. All rights reserved.
//

import Foundation
import Accelerate

public extension vImage_CGImageFormat {
    
    public static func planar8vImage_CGImageFormat() -> vImage_CGImageFormat {
        return vImage_CGImageFormat(bitsPerComponent: 8,
                                    bitsPerPixel: 8,
                                    colorSpace: Unmanaged.passUnretained(CGColorSpaceCreateDeviceGray()),
                                    bitmapInfo: .alphaInfoMask,
                                    version: 0,
                                    decode: nil,
                                    renderingIntent: .defaultIntent)
    }
    
}

public extension vImage_Buffer {
    
    public func printGrayFirstValues() {
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
    
    public func printRGBFirstValues() {
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
