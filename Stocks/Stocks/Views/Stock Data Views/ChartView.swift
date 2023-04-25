//
//  ChartView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/19/23.
//
// Shows charts for each stocks

import Charts
import SwiftUI
import XCAStocksAPI

struct ChartView: View {
    
    let data: ChartDataV
    @ObservedObject var vm: ChartViewModel
    
    var body: some View {
        chart
            .chartXAxis { chartXAxis }
            .chartXScale(domain: data.xAxisData.axisStart...data.xAxisData.axisEnd)
            .chartYAxis { chartYAxis }
            .chartYScale(domain: data.yAxisData.axisStart...data.yAxisData.axisEnd)
            .chartPlotStyle() { chartPlotStyle($0) }
            .chartOverlay { proxy in
                GeometryReader { gProxy in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { onChangeDrag(value: $0, chartProxy: proxy, geometryProxy: gProxy) }
                            .onEnded { _ in
                                vm.selectedX = nil
                            }
                        )
                }
            }
    }
    
    private var chart: some View {
        Chart {
            ForEach(Array(zip(data.items.indices, data.items)), id: \.0) { index, item in
                LineMark(
                    x: .value("Time", index),
                    y: .value("Price", item.value))
                .foregroundStyle(vm.foregroundMarkColor)
                
                AreaMark(
                    x: .value("Time", index),
                    yStart: .value("Min", data.yAxisData.axisStart),
                    yEnd: .value("Max", item.value)
                )
                .opacity(0.4)
                
                if let previousClose = data.previousCloseRuleMarkValue {
                    RuleMark(y: .value("Previous Close", previousClose))
                        .lineStyle(.init(lineWidth: 0.1, dash: [2]))
                        .foregroundStyle(.gray.opacity(0.2))
                    
                }
                
                if let (selectedX, text) = vm.selectedXRuleMark {
                    RuleMark(x: .value("Selected timestamp", selectedX))
                        .lineStyle(.init(lineWidth: 1))
                        .annotation {
                            Text(text)
                                .font(.system(size: 14))
                                .foregroundColor(.blue)
                        }
                        .foregroundStyle(vm.foregroundMarkColor)
                }
                
            }
        }
    }
    
    private var chartXAxis: some AxisContent {
        AxisMarks(values: .stride(by: data.xAxisData.strideBy)) { value in
            if let text = data.xAxisData.map[String(value.index)] {
                AxisGridLine(stroke: .init(lineWidth: 0.3))
                AxisTick(stroke: .init(lineWidth: 0.3))
                AxisValueLabel(collisionResolution: .greedy()) {
                    Text(text)
                        .foregroundColor(Color(uiColor: .label))
                        .font(.caption.bold())
                }
            }
            
            
        }
    }
    
    private var chartYAxis: some AxisContent {
        AxisMarks(preset: .extended, values: .stride(by: data.yAxisData.strideBy)) { value in
            if let y = value.as(Double.self),
               let text = data.yAxisData.map[y.roundedString] {
                AxisGridLine(stroke: .init(lineWidth: 0.3))
                AxisTick(stroke: .init(lineWidth: 0.3))
                AxisValueLabel(anchor: .topLeading, collisionResolution: .greedy) {
                    Text(text)
                        .foregroundColor(Color(uiColor: .label))
                        .font(.caption.bold())
                }
            }
        }
    }
    
    
    private func chartPlotStyle(_ plotContent: ChartPlotContent) -> some View {
        plotContent
            .frame(height: 200)
            .overlay {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.5))
                    .mask(ZStack {
                        VStack {
                            Spacer()
                            Rectangle().frame(height: 1)
                        }
                        
                        HStack {
                            Spacer()
                            Rectangle().frame(width: 0.3)
                        }
                    })
            }
    }
    
    private func onChangeDrag(value: DragGesture.Value, chartProxy: ChartProxy, geometryProxy: GeometryProxy) {
        let xCurrent = value.location.x - geometryProxy[chartProxy.plotAreaFrame].origin.x
        if let index: Double = chartProxy.value(atX: xCurrent),
           index >= 0,
           Int(index) <= data.items.count - 1 {
            self.vm.selectedX = Int(index)
        }
    }
    
}

