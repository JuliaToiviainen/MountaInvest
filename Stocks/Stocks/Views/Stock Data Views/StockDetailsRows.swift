//
//  StockDetailsRows.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/1/23.
//
// Shows additional details for each stock

import SwiftUI

struct StockItem: Identifiable {
    
    let id = UUID()
    let rows: [RowItem]
    
    struct RowItem: Identifiable {
        
        let id = UUID()
        let title: String
        let value: String
    }
}

struct StockDetailsRows: View {
    
    let item: StockItem
        
    var body: some View {
        VStack(spacing: 7) {
            ForEach(item.rows) {
                row in
                HStack(alignment: .lastTextBaseline) {
                    Text(row.title).foregroundColor(.gray)
                    Spacer()
                    Text(row.value)
                }
            }
        }
        .frame(width: 150)
    }
}

