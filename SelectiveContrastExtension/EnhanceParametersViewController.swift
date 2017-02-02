//
//  EnhanceParametersViewController.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa

public protocol EnhanceParametersViewControllerDelegate {
    func parametersDidChange(smin: Int, smax: Int, N: Int)
}

public final class EnhanceParametersViewController: NSViewController {

    // MARK: - Constants
    private let backgroundColor = NSColor(calibratedRed: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)
    
    
    // MARK: - Properties
    var delegate: EnhanceParametersViewControllerDelegate?
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var sliderN: NSSlider!
    @IBOutlet weak var sliderSmax: NSSlider!
    
    @IBOutlet weak var lableN: NSTextField!
    @IBOutlet weak var lableSmax: NSTextField!
    
    // MARK: - View controller lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
    }
    
    private func setupBackground() {
        view.wantsLayer = true
        view.layer!.backgroundColor = backgroundColor.cgColor
    }
    
    // MARK: - IBActions
    
    @IBAction func sliderNAction(_ sender: NSSlider) {
        lableN.stringValue = "N = \(sender.integerValue)"
        delegate?.parametersDidChange(smin: 0, smax: Int(sliderSmax.intValue), N: Int(sliderN.intValue))
    }
    
    @IBAction func sliderSmaxAction(_ sender: NSSlider) {
        lableSmax.stringValue = "Smax = \(sender.integerValue)"
        delegate?.parametersDidChange(smin: 0, smax: Int(sliderSmax.intValue), N: Int(sliderN.intValue))
    }
    
}
