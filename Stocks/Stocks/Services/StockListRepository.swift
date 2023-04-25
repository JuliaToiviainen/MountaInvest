//
//  StockListRepository.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/16/23.
//
// from Alfian Losari Youtube series

import Foundation
import XCAStocksAPI
import Firebase


protocol StockListRepository {
    
    func save(_ current: [Ticker]) async throws
    func load() async throws -> [Ticker]
}

class StockPlistRepository: StockListRepository {
    
    private var saved: [Ticker]?
    private let filename: String
    
    private var url: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appending(component: "\(filename).plist")
    }
    
    init(filename: String = "my_tickers") {
        self.filename = filename
    }
    
    func save(_ current: [Ticker]) throws {
        if let saved, saved == current{
            return
        }
        
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        let data = try encoder.encode(current)
        try data.write(to: url, options: [.atomic])
        self.saved = current
    }
    
    func load() throws -> [Ticker] {
        let data = try Data(contentsOf: url)
        let current = try PropertyListDecoder().decode([Ticker].self, from: data)
        self.saved = current
        return current
    }
}
