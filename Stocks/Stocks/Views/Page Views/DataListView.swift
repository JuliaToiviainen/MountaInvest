//
//  DataListView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/5/23.
//
// List of stock that is found and how it will be display

import SwiftUI
import Firebase

struct DataListView: View {
    
    let data: DataList
    
    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing:5){
                
                Text(data.symbol).font(.headline.bold())
                if let name = data.name{
                    Text(name)
                        .font(.subheadline)
                        .foregroundColor(Color(uiColor: .secondaryLabel))
                }
            }
            Spacer()
            if let (price, change) = data.price {
                VStack(alignment: .trailing, spacing: 4){
                    Text(price)
                    priceChangeView(text: change)
                }
                .font(.headline.bold())
            }
        }
    }

    
    @ViewBuilder
    //making color change is change positive or negative and the color box design
    func priceChangeView(text: String) -> some View{
        if case .main = data.type {
            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(text.hasPrefix("-") ? .red : .green)
                    .frame(height: 24)
                Text(text)
                    .foregroundColor(.white)
                    .font(.caption.bold())
                    .padding(.horizontal, 7)
            }.fixedSize()
        }
        else {
            Text(text)
                .foregroundColor(text.hasPrefix("-") ? .red : .green)
        }
    }
}

