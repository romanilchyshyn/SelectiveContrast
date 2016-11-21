//
//  Enhance.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Foundation

enum Enhance {
    
    case Dark(T: Double, a: Double)
    case Global(alpha: Double)
    
    var ta: (T: Double, a: Double)? {
        get {
            switch self {
            case .Dark(let T, let a): return (T, a)
            case .Global: return nil
            }
        }
    }
    
    var alpha: Double? {
        get {
            switch self {
            case .Global(let alpha): return alpha
            case .Dark: return nil
            }
        }
    }
}
