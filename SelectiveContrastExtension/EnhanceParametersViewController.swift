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
    
    private let minT = 0.0
    private let maxT = 255.0
    private let incrementT = 1.0
    
    private let minA = 0.0
    private let maxA = 10.0
    private let incrementA = 0.05
    
    private let minAlpha = 0.0
    private let maxAlpha = 2.0
    private let incrementAlpha = 0.01
    
    // MARK: Properties
    var enhance: Enhance = .Dark(T: 50, a: 2.5)
//    {
//        didSet {
//            switch enhance {
//            case .Dark(let T, let a):
//                sliderT.doubleValue = T
//                sliderA.doubleValue = a
//                
//                enhanceDarkRadioButton.state = NSOnState
//                enhanceGlobalRadioButton.state = NSOffState
//            case .Global(let alpha):
//                sliderAlpha.doubleValue = alpha
//                
//                enhanceDarkRadioButton.state = NSOffState
//                enhanceGlobalRadioButton.state = NSOnState
//            }
//        }
//    }
    
    // MARK: IBOutlets
    @IBOutlet weak var enhanceDarkRadioButton: NSButton!
    @IBOutlet weak var enhanceGlobalRadioButton: NSButton!
    
    @IBOutlet weak var sliderT: NSSlider!
    @IBOutlet weak var sliderA: NSSlider!
    @IBOutlet weak var sliderAlpha: NSSlider!
    
    @IBOutlet weak var textFieldT: NSTextField!
    @IBOutlet weak var textFieldA: NSTextField!
    @IBOutlet weak var textFieldAlpha: NSTextField!
    
    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        initializeSliders()
        
        
    }
    
    func setupBackground() {
        view.wantsLayer = true
        view.layer!.backgroundColor = backgroundColor.cgColor
    }
    
    func initializeSliders() {
        sliderT.minValue = minT
        sliderT.maxValue = maxT
        sliderT.altIncrementValue = incrementT
        
        sliderA.minValue = minA
        sliderA.maxValue = maxA
        sliderA.altIncrementValue = incrementA
        
        sliderAlpha.minValue = minAlpha
        sliderAlpha.maxValue = maxAlpha
        sliderAlpha.altIncrementValue = incrementAlpha
    }
    
}
