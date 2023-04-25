//
//  ChartData.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/13/23.
//
// For chart view the variables needed

import Foundation
import SwiftUI

struct ChartDataV: Identifiable {
    
    let id = UUID()
        let xAxisData: ChartAxisData
        let yAxisData: ChartAxisData
        let items: [ChartViewItem]
        let lineColor: Color
        let previousCloseRuleMarkValue: Double?
        
    }

    struct ChartViewItem: Identifiable {
        
        let id = UUID()
        let timestamp: Date
        let value: Double
        
    }

    struct ChartAxisData {
        
        let axisStart: Double
        let axisEnd: Double
        let strideBy: Double
        let map: [String: String]
        
    }
