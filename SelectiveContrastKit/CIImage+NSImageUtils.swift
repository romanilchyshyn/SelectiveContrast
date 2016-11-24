//
//  CIImage+NSImageUtils.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/24/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Foundation

public extension CIImage {

    convenience init?(image: NSImage) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        self.init(cgImage: cgImage)
    }

}
