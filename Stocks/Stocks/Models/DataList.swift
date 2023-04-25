//
//  DataList.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/5/23.
//
// For Data list the variables needed, saved not functioning as wanted, decided to save it a database afterall

import Foundation

typealias PriceChange = (price: String, change: String)

struct DataList {
    
    enum RowType {
        case main
        case search(isSaved: Bool, onButtonTapped: () -> ())
    }
    
    let symbol: String
    let name: String?
    let price: PriceChange?
    let type: RowType
}
