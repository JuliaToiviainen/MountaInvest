//
//  Quote.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/15/23.
//
// Quotes for stocks from Alfian Losari Youtube series

import Foundation
import XCAStocksAPI

extension Quote{
    
    var isTrading: Bool{
        guard let marketState, marketState == "REGULAR"
        else {
            return false
        }
        return true
    }
    
    var regularPriceText: String?{
        Utils.format(value: regularMarketPrice)
    }
    
    var regularDiffText: String?{
        guard let text = Utils.format(value: regularMarketChange)
        else{
            return nil
        }
        return text.hasPrefix("-") ? text: "+\(text)"
    }
    
    
    var postPriceText: String?{
        Utils.format(value: postMarketPrice)
    }
    
    var postDiffText: String?{
        guard let text = Utils.format(value: postMarketChange)
        else{
            return nil
        }
        return text.hasPrefix("-") ? text: "+\(text)"
    }
    
    var highText: String{
        Utils.format(value: regularMarketDayHigh) ?? "-"
    }
    
    var openText: String {
        Utils.format(value: regularMarketOpen) ?? "-"
    }
    
    var lowText: String {
        Utils.format(value: regularMarketDayLow) ?? "-"
    }
    
    var volText: String {
        regularMarketVolume?.formatUsingAbbrevation() ?? "-"
    }
    
    var peText: String {
        Utils.format(value: trailingPE) ?? "-"
    }
    
    var mktCapText: String {
        marketCap?.formatUsingAbbrevation() ?? "-"
    }
    
    var fiftyTwoWHText: String {
        Utils.format(value: fiftyTwoWeekHigh) ?? "-"
    }
    
    var fiftyTwoWLText: String {
        Utils.format(value: fiftyTwoWeekLow) ?? "-"
    }
    
    var avgVolText: String {
        averageDailyVolume3Month?.formatUsingAbbrevation() ?? "-"
    }
    
    var yieldText: String { "-" }
    var betaText: String { "-" }
    
    var epsText: String {
        Utils.format(value: epsTrailingTwelveMonths) ?? "-"
    }
    
    var colItems: [StockItem] {
        [
            StockItem(rows: [
                StockItem.RowItem(title: "Open", value: openText),
                StockItem.RowItem(title: "High", value: highText),
                StockItem.RowItem(title: "Low", value: lowText)
            ]), StockItem(rows: [
                StockItem.RowItem(title: "Vol", value: volText),
                StockItem.RowItem(title: "P/E", value: peText),
                StockItem.RowItem(title: "Mkt Cap", value: mktCapText)
            ]), StockItem(rows: [
                StockItem.RowItem(title: "52W H", value: fiftyTwoWHText),
                StockItem.RowItem(title: "52W L", value: fiftyTwoWLText),
                StockItem.RowItem(title: "Avg Vol", value: avgVolText)
            ]), StockItem(rows: [
                StockItem.RowItem(title: "Yield", value: yieldText),
                StockItem.RowItem(title: "Beta", value: betaText),
                StockItem.RowItem(title: "EPS", value: epsText)
            ])
        ]
    }
    
}
