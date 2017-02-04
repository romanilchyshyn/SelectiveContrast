//
//  EnhanceParametersViewController.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa
import Charts

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
    
    @IBOutlet weak var lineChart: LineChartView!
    
    // MARK: - View controller lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupChart()
    }
    
    private func setupBackground() {
        view.wantsLayer = true
        view.layer!.backgroundColor = backgroundColor.cgColor
    }
    
    private func setupChart() {
        
        let ys1 = Array(1..<10).map { x in return sin(Double(x) / 2.0 / 3.141 * 1.5) }
        let ys2 = Array(1..<10).map { x in return cos(Double(x) / 2.0 / 3.141) }
        
        let yse1 = ys1.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        let yse2 = ys2.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let data = LineChartData()
        let ds1 = LineChartDataSet(values: yse1, label: "Hello")
        ds1.colors = [NSUIColor.red]
        data.addDataSet(ds1)
        
        let ds2 = LineChartDataSet(values: yse2, label: "World")
        ds2.colors = [NSUIColor.blue]
        data.addDataSet(ds2)
        self.lineChart.data = data
        
        self.lineChart.gridBackgroundColor = NSUIColor.white
        self.lineChart.drawBordersEnabled = true
        
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
