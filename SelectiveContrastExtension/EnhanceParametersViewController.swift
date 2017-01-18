//
//  EnhanceParametersViewController.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa

public protocol EnhanceParametersViewControllerDelegate {
    func parametersDidChange(param: Int)
}

public final class EnhanceParametersViewController: NSViewController {

    // MARK: - Constants
    private let backgroundColor = NSColor(calibratedRed: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)
    
    
    // MARK: - Properties
    var delegate: EnhanceParametersViewControllerDelegate?
    
    var integerNumberFormatter = NumberFormatter()
    var doubleNumberFormatter = NumberFormatter()
    
    // MARK: - IBOutlets


    // MARK: - View controller lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupNumberFormatters()
    }
    
    private func setupBackground() {
        view.wantsLayer = true
        view.layer!.backgroundColor = backgroundColor.cgColor
    }
    
    private func setupNumberFormatters() {
        doubleNumberFormatter.numberStyle = .decimal
        doubleNumberFormatter.maximumFractionDigits = 2
        doubleNumberFormatter.minimumFractionDigits = 2
    }
    
    // MARK: - IBActions
    
    @IBAction func sliderAction(_ sender: NSSlider) {
        self.delegate?.parametersDidChange(param: Int(sender.intValue))
    }
    
}
