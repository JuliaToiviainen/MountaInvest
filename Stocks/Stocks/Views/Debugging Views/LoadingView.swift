//
//  LoadingView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/15/23.
//
// If loading, this view will be shown

import SwiftUI

struct LoadingView: View {
    
    let text: String
    
    var body: some View {
        HStack{
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
            Text(text)
                .font(.headline)
                .foregroundColor(Color(uiColor: .secondaryLabel))
            Spacer()
        }
        .padding(64)
        .lineLimit(3)
        .multilineTextAlignment(.center)
    }
}

