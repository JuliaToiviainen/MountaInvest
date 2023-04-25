//
//  StocksAPI.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/16/23.
//
// from Alfian Losari Youtube series

import Foundation
import XCAStocksAPI

protocol StocksAPI {
    
    func searchTickers(query: String, isEquityTypeOnly: Bool) async throws -> [Ticker]
    func fetchQuotes(symbols: String) async throws -> [Quote]
    func fetchChartData(tickerSymbol: String, range: ChartRange) async throws -> ChartData?
    
}

extension XCAStocksAPI: StocksAPI{
    
}
