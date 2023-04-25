//
//  DateRangeView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/1/23.
//
// Shows date ranges for stocks

import SwiftUI
import XCAStocksAPI

struct DateRangeView: View {
    
    let rangeTypes = ChartRange.allCases
    @Binding var selectedRange: ChartRange
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 10) {
                ForEach(self.rangeTypes) { dateRange in
                    Button {
                        self.selectedRange = dateRange
                    } label: {
                        Text(dateRange.title)
                            .font(.callout.bold())
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .background {
                        if dateRange == selectedRange {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.3))
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .scrollIndicators(.hidden)
    }
}
