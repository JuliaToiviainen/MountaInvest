//
//  SearchViewModel.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/15/23.
//
// For fetching from Yahoo

import Foundation
import Combine
import SwiftUI
import XCAStocksAPI

@MainActor

class SearchViewModel: ObservableObject{
    
    @Published var query: String = ""
    @Published var phase: Fetching<[Ticker]> = .initial
    
    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var tickers: [Ticker] {
        phase.value ?? []
    }
    var error: Error? {
        phase.error
    }
    var isSearching: Bool {
        !trimmedQuery.isEmpty
    }
    
    var emptyListText: String{
        "Symbol not found for \n\"\(query)\""
    }
    
    var loadingListText: String{
        "Loading for \n\"\(query)\""
    }
    
    private var cancellables = Set<AnyCancellable>()
    private let stocksAPI: StocksAPI
    
    init(query: String = "", stocksAPI: StocksAPI = XCAStocksAPI()) {
        self.query = query
        self.stocksAPI = stocksAPI
        
        startObserving()
    }
    
    private func startObserving(){
        $query
            .debounce(for: 0.25, scheduler: DispatchQueue.main)
            .sink{
                _ in
                Task {
                    [weak self] in await self?.searchStocks()
                }
            }
            .store(in: &cancellables)
        $query
            .filter{
                $0.isEmpty
            }
            .sink{
                [weak self] _ in self?.phase = .initial
            }
            .store(in: &cancellables)
    }
    
    func searchStocks() async{
        let searchQuery = trimmedQuery
        guard !searchQuery.isEmpty
        else {
            return
        }
        phase = .fetching
        
        do {
            let tickers = try await stocksAPI.searchTickers(query: searchQuery, isEquityTypeOnly: true)
            if searchQuery != trimmedQuery {
                return
            }
            if tickers.isEmpty {
                phase = .empty
            }
            else {
                phase = .success(tickers)
            }
        }
        catch {
            if searchQuery != trimmedQuery {
                return
            }
            print(error.localizedDescription)
            phase = .failure(error)
        }
    }
}
