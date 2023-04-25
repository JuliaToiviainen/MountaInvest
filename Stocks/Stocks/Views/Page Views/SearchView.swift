//
//  SearchView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/15/23.
//
// This view provides the search view from where the user can search more stocks it also calls the stock sheets views to display. Offers differents when searching,  loading, empty, searching and the results if found


import SwiftUI
import XCAStocksAPI
import FirebaseFirestore

struct SearchView: View {
    
    @EnvironmentObject var appVM: AppViewModel
    @StateObject var quotesVM = QuotesViewModel()
    @ObservedObject var searchVM: SearchViewModel
    
    
    var body: some View {
        
            //list to show all apps found for current search, calls DataListView
            List(searchVM.tickers) {
                ticker in DataListView(
                    data: .init(
                        symbol: ticker.symbol,
                        name: ticker.shortname,
                        price: quotesVM.priceForTicker(ticker),
                        type: .search(
                            isSaved: appVM.isAddedToMyStocks(ticker: ticker),
                            onButtonTapped: {
                                Task {
                                    @MainActor in  appVM.toggleStocks(ticker)
                                }
                            }
                        )
                    )
                )
                .onTapGesture{
                    appVM.selectedTicker = ticker
                }
            }
            .task(id: searchVM.tickers){
                await quotesVM.fetchQuotes(tickers: searchVM.tickers)
            }
            .refreshable {
                await quotesVM.fetchQuotes(tickers: searchVM.tickers)
            }
    }
    
    @ViewBuilder
    private var listSearchOverview: some View {
        switch searchVM.phase{
        case .failure(let error):
            ErrorView(error: error.localizedDescription){
                Task {
                    await searchVM.searchStocks ()
                }
            }
        case .empty:
            EmptyViewShow(text: searchVM.emptyListText)
        case .fetching:
            LoadingView(text: searchVM.loadingListText)
        default:
            EmptyView()
        }
    }
}

