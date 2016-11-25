//
//  EnhanceParametersViewController.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa

import RxCocoa
import RxSwift

class EnhanceParametersViewController: NSViewController {

    // MARK: Constants
    private let defaultT = 50.0
    private let defaultA = 2.5
    private let defaultAlpha = 0.8
    
    private let backgroundColor = NSColor(calibratedRed: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)
    
    private let minT = 0.0
    private let maxT = 255.0
    private let incrementT = 1.0
    
    private let minA = 0.0
    private let maxA = 10.0
    private let incrementA = 0.01
    
    private let minAlpha = 0.0
    private let maxAlpha = 2.0
    private let incrementAlpha = 0.01
    
    // MARK: Properties
    private(set) var enhance = Variable(Enhance.Dark(T: 50, a: 2.5))
    
    var integerNumberFormatter = NumberFormatter()
    var doubleNumberFormatter = NumberFormatter()
    
    let disposeBag = DisposeBag()
    
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
        setupNumberFormatters()
        initializeSliders()
        
        bindSliders()
        
        
        let enhanceDarkRadioButtonState = enhanceDarkRadioButton.rx.state.share()
        let enhanceGlobalRadioButtonState = enhanceGlobalRadioButton.rx.state.share()
        
        enhanceDarkRadioButtonState
            .filter { $0 == NSOnState }
            .map { _ in NSOffState } .debug()
            .bindTo(enhanceGlobalRadioButton.rx.state)
            .addDisposableTo(disposeBag)
        
        enhanceGlobalRadioButtonState
            .filter { $0 == NSOnState }
            .map { _ in NSOffState } .debug()
            .bindTo(enhanceDarkRadioButton.rx.state)
            .addDisposableTo(disposeBag)
        
        
        enhanceDarkRadioButtonState.filter { $0 == NSOnState }
            .map { [unowned self] (Int) -> Enhance in
                return Enhance.Dark(T: self.sliderT.doubleValue, a: self.sliderA.doubleValue)
            }
            .bindTo(enhance)
            .addDisposableTo(disposeBag)
        
        
        enhanceGlobalRadioButtonState.filter { $0 == NSOnState }
            .map { [unowned self] (Int) -> Enhance in
                return Enhance.Global(alpha: self.sliderAlpha.doubleValue)
            }
            .bindTo(enhance)
            .addDisposableTo(disposeBag)
        
    }
    
    func setupBackground() {
        view.wantsLayer = true
        view.layer!.backgroundColor = backgroundColor.cgColor
    }
    
    func bindSliders() {
        let sliderTvalue = sliderT.rx.value.shareReplay(1)
        sliderTvalue.asObservable().map { [unowned self] in self.integerNumberFormatter.string(from: NSNumber(value: $0)) ?? "" }
            .bindTo(textFieldT.rx.text)
            .addDisposableTo(disposeBag)
        
        let doubleFormatStringMap: ((Double) -> String) = { [unowned self] in self.doubleNumberFormatter.string(from: NSNumber(value: $0)) ?? "" }
        let sliderAvalue = sliderA.rx.value.shareReplay(1)
        sliderAvalue.map(doubleFormatStringMap)
            .bindTo(textFieldA.rx.text)
            .addDisposableTo(disposeBag)
        
        let sliderAlphaValue = sliderAlpha.rx.value.share()
        sliderAlphaValue.map(doubleFormatStringMap)
            .bindTo(textFieldAlpha.rx.text)
            .addDisposableTo(disposeBag)
        

        Observable.combineLatest(sliderTvalue, sliderAvalue) { Enhance.Dark(T: $0, a: $1) }
            .bindTo(enhance)
            .addDisposableTo(disposeBag)
        sliderAlphaValue.map { Enhance.Global(alpha: $0) }
            .bindTo(enhance)
            .addDisposableTo(disposeBag)
    }
    
    func initializeSliders() {
        sliderT.minValue = minT
        sliderT.maxValue = maxT
        sliderT.doubleValue = defaultT
        sliderT.altIncrementValue = incrementT
        sliderT.allowsTickMarkValuesOnly = true
        sliderT.isContinuous = true
        
        sliderA.minValue = minA
        sliderA.maxValue = maxA
        sliderA.doubleValue = defaultA
        sliderA.altIncrementValue = incrementA
        sliderA.allowsTickMarkValuesOnly = true
        sliderA.isContinuous = true
        
        sliderAlpha.minValue = minAlpha
        sliderAlpha.maxValue = maxAlpha
        sliderAlpha.doubleValue = defaultAlpha
        sliderAlpha.altIncrementValue = incrementAlpha
        sliderAlpha.allowsTickMarkValuesOnly = true
        sliderAlpha.isContinuous = true
    }
    
    func setupNumberFormatters() {
        doubleNumberFormatter.numberStyle = .decimal
        doubleNumberFormatter.maximumFractionDigits = 2
        doubleNumberFormatter.minimumFractionDigits = 2
    }
    
}
