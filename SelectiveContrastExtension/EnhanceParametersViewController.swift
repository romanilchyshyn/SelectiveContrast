//
//  EnhanceParametersViewController.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa

class EnhanceParametersViewController: NSViewController {

    // MARK: Constants
    private let backgroundColor = NSColor(calibratedRed: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)
    
    
    // MARK: Properties
    
    var integerNumberFormatter = NumberFormatter()
    var doubleNumberFormatter = NumberFormatter()
    
    // MARK: IBOutlets

    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupNumberFormatters()
    }
    
    func setupBackground() {
        view.wantsLayer = true
        view.layer!.backgroundColor = backgroundColor.cgColor
    }
    
    func setupNumberFormatters() {
        doubleNumberFormatter.numberStyle = .decimal
        doubleNumberFormatter.maximumFractionDigits = 2
        doubleNumberFormatter.minimumFractionDigits = 2
    }
    
}
