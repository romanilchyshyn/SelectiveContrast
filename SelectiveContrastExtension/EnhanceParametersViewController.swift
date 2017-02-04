//
//  EnhanceParametersViewController.swift
//  SelectiveContrast
//
//  Created by Roman Ilchyshyn on 11/21/16.
//  Copyright © 2016 Roman Ilchyshyn. All rights reserved.
//

import Cocoa
import Charts
import SelectiveContrastKit

public protocol EnhanceParametersViewControllerDelegate: class {
    
    func parametersDidChange(smin: Int, smax: Int, N: Int)
    
}

public final class EnhanceParametersViewController: NSViewController, PhotoEditingViewControllerDelegate {

    // MARK: - Constants
    private let backgroundColor = NSColor(calibratedRed: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)
    
    
    // MARK: - Properties
    weak var delegate: EnhanceParametersViewControllerDelegate?
    
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var sliderN: NSSlider!
    @IBOutlet weak var sliderSmax: NSSlider!
    
    @IBOutlet weak var lableN: NSTextField!
    @IBOutlet weak var lableSmax: NSTextField!
    
    @IBOutlet weak var inHistogramChart: LineChartView!
    @IBOutlet weak var outHistogramChart: LineChartView!
    @IBOutlet weak var transformCurveChart: LineChartView!
    
    
    // MARK: - View controller lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackground()
        setupCharts()
    }
    
    private func setupBackground() {
        view.wantsLayer = true
        view.layer!.backgroundColor = backgroundColor.cgColor
    }
    
    private func setupCharts() {
        prepareChart(chart: inHistogramChart)
        inHistogramChart.data = LineChartData()
        prepareChart(chart: outHistogramChart)
        outHistogramChart.data = LineChartData()
        
        prepareChart(chart: transformCurveChart)
        transformCurveChart.data = ScatterChartData()
        transformCurveChart.heightAnchor.constraint(equalTo: transformCurveChart.widthAnchor).isActive = true
    }
    
    private func prepareChart(chart: BarLineChartViewBase) {
        chart.drawBordersEnabled = true
        
        chart.noDataText = ""
        chart.chartDescription?.text = ""
        
        chart.drawMarkers = false
        chart.legend.enabled = false
        
        chart.xAxis.drawLabelsEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = false
        
        chart.leftAxis.drawLabelsEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        
        chart.rightAxis.drawLabelsEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
    }
    
    // MARK: - PhotoEditingViewControllerDelegate
    
    func plotDataDidUpdate(in outputContext: OutputContext) {
        let inputHistogram = LineChartData()
        addHistogram(histogram: outputContext.inHistogram.r, for: inputHistogram, color: NSColor.red)
        addHistogram(histogram: outputContext.inHistogram.g, for: inputHistogram, color: NSColor.green)
        addHistogram(histogram: outputContext.inHistogram.b, for: inputHistogram, color: NSColor.blue)
        self.inHistogramChart.data = inputHistogram
        
        let outputHistogram = LineChartData()
        addHistogram(histogram: outputContext.outHistogram.r, for: outputHistogram, color: NSColor.red)
        addHistogram(histogram: outputContext.outHistogram.g, for: outputHistogram, color: NSColor.green)
        addHistogram(histogram: outputContext.outHistogram.b, for: outputHistogram, color: NSColor.blue)
        self.outHistogramChart.data = outputHistogram
        
        // -----
        
        var transformEntriesRed = [ChartDataEntry]()
        var transformEntriesGreen = [ChartDataEntry]()
        var transformEntriesBlue = [ChartDataEntry]()
        for i in stride(from: 0, to: outputContext.xs.r.count, by: 1) {
            transformEntriesRed.append(ChartDataEntry(x: outputContext.xs.r[i], y: outputContext.ys[i]))
            transformEntriesGreen.append(ChartDataEntry(x: outputContext.xs.g[i], y: outputContext.ys[i]))
            transformEntriesBlue.append(ChartDataEntry(x: outputContext.xs.b[i], y: outputContext.ys[i]))
        }
        
        let transformDataSetRed = LineChartDataSet(values: transformEntriesRed, label: "")
        let transformDataSetGreen = LineChartDataSet(values: transformEntriesGreen, label: "")
        let transformDataSetBlue = LineChartDataSet(values: transformEntriesBlue, label: "")
        
        transformDataSetRed.colors = [NSColor.red]
        transformDataSetRed.drawValuesEnabled = false
        transformDataSetRed.drawCirclesEnabled = false
        transformDataSetGreen.colors = [NSColor.green]
        transformDataSetGreen.drawValuesEnabled = false
        transformDataSetGreen.drawCirclesEnabled = false
        transformDataSetBlue.colors = [NSColor.blue]
        transformDataSetBlue.drawValuesEnabled = false
        transformDataSetBlue.drawCirclesEnabled = false
        
        let transformData = LineChartData()
        transformData.addDataSet(transformDataSetRed)
        transformData.addDataSet(transformDataSetGreen)
        transformData.addDataSet(transformDataSetBlue)
        
        transformCurveChart.data = transformData
    }
    
    func addHistogram(histogram: [UInt], for data: LineChartData, color: NSColor) {
        let hist = histogram.map { Double($0) }
        let histDataEntry = hist.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
        
        let redDataSet = LineChartDataSet(values: histDataEntry, label: "")
        redDataSet.drawCirclesEnabled = false
        redDataSet.colors = [color]
        data.addDataSet(redDataSet)
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
