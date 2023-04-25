//
//  ErrorView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/15/23.
//
// If error, this view will be shown

import SwiftUI

struct ErrorView: View {
    
    let error: String
    var retryCallBack: (() -> ())?
    
    var body: some View {
        HStack{
            Spacer()
            VStack(spacing: 16){
                Text(error)
                if let retryCallBack{
                    Button("Retry", action: retryCallBack)
                        .buttonStyle(.borderedProminent)
                }
            }
            Spacer()
        }
        .padding(64)
    }
}

