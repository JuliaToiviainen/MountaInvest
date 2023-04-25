//
//  AppViewModel.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/15/23.
//
// Provides the fundaments for the app, function to Yahoo's finance API

import Foundation
import SwiftUI
import XCAStocksAPI

@MainActor

class AppViewModel: ObservableObject{
    
    @Published var tickers: [Ticker] = []{
        didSet {
            saveStocks()
        }
    }
    @Published var selectedTicker: Ticker?
    
    @State private var data: [String: Any] = [:]
    
    var emptyStocksText = "Search stocks and add to follow"
    var titleText = "MountaInvest"
    @Published var subText: String
    var attributionText = "App still in progress"
    
    
    private let subDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM"
    return df
    }()
    
    let stockListRepository: StockListRepository
    
    init(repository: StockListRepository = StockPlistRepository()){
        self.stockListRepository = repository
        self.subText = subDateFormatter.string(from: Date())
    }

    private func saveStocks(){
        Task {
           [weak self] in
            guard let self = self else {
                return
            }
            do {
                try await stockListRepository.save(self.tickers)
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func loadStocks(){
        Task {
            [weak self] in
            guard let self = self else {
                return
            }
            do {
                self.tickers = try await stockListRepository.load()
            }
            catch {
                print(error.localizedDescription)
                self.tickers = []
            }
        }
    }
    
    func removeStocks(atOffsets offset: IndexSet){
        tickers.remove(atOffsets: offset)
    }
    
    func isAddedToMyStocks(ticker: Ticker) -> Bool{
        tickers.first {$0.symbol == ticker.symbol} != nil
    }
    
    func toggleStocks(_ ticker: Ticker){
        if isAddedToMyStocks(ticker: ticker){
            removeFromMyStocks(ticker: ticker)
        }
        else {
            addToMyStocks(ticker: ticker)
        }
    }
    
    private func removeFromMyStocks(ticker: Ticker){
        guard let index = tickers.firstIndex(where: {$0.symbol == ticker.symbol})
        else {
            return
        }
        tickers.remove(at: index)
    }
    
    private func addToMyStocks(ticker: Ticker){
        tickers.append(ticker)
    }
    func openYahooFinance(){
        let url = URL(string: "https://finance.yahoo.com")!
        guard UIApplication.shared.canOpenURL(url)
        else{
            return
        }
        UIApplication.shared.open(url)
    }
}
