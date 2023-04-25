//
//  ContentView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/5/23.
//
// Main list view of the stocks when searching them. Provides the overall picture.

import SwiftUI
import XCAStocksAPI
import Firebase

struct MainListView: View {
    
    @EnvironmentObject var appVM: AppViewModel
    @StateObject var quotesVM = QuotesViewModel()
    @StateObject var searchVM = SearchViewModel()

    
    var body: some View {
        
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing:-4){
                    GroupBox(label: Label("", systemImage: "creditcard.fill")
                        .foregroundColor(.black)){
                            Text("Search any stocks")
                            
                        }.padding()
                }
                VStack{
                    dataListView
                        .overlay {
                            overlay
                        }
                        .searchable(text: $searchVM.query)
                        .task(id: appVM.tickers){
                            await quotesVM.fetchQuotes(tickers: appVM.tickers)
                        }
                        .refreshable {
                            await quotesVM.fetchQuotes(tickers: appVM.tickers)
                        }
                        .sheet(item: $appVM.selectedTicker){
                            StockTickerView(chartVM: ChartViewModel(ticker: $0, apiService: quotesVM.stocksAPI), quoteVM: .init(ticker: $0, stocksAPI: quotesVM.stocksAPI))
                        }
                }
                .toolbar{
                    ToolbarItemGroup(placement: .bottomBar) {
                        NavigationLink(destination: HomeView()) {
                            VStack{
                                Image(systemName: "house")
                                Text("Home")
                                    .font(.system(size: 14))
                            }
                            .padding(.top)
                        }
                        Spacer()
                        NavigationLink(destination: PortfolioView()) {
                            VStack {
                                Image(systemName: "star")
                                Text("Portfolio")
                                    .font(.system(size: 14))
                            }
                            .padding(.top)
                        }
                        Spacer()
                        NavigationLink(destination: MainListView()) {
                            VStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search")
                                    .font(.system(size: 14))
                            }
                            .padding(.top)
                        }
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            VStack {
                                Image(systemName: "gear")
                                Text("Settings")
                                    .font(.system(size: 14))
                            }
                            .padding(.top)
                        }
                    }
                }
            }
        }
        // no back arrow
        .navigationBarBackButtonHidden(true)
    }
    
    private var dataListView: some View {

       List {
            ForEach(appVM.tickers) {
                ticker in DataListView(data: .init(symbol: ticker.symbol, name: ticker.shortname, price: quotesVM.priceForTicker(ticker), type: .main))
                .contentShape(Rectangle())
                .onTapGesture {
                    appVM.selectedTicker = ticker
                }
            }
        }
    }
    
    @ViewBuilder
    private var overlay: some View{
        if appVM.tickers.isEmpty{
            EmptyViewShow(text: appVM.emptyStocksText)
        }
        
        if searchVM.isSearching {
            SearchView(searchVM: searchVM)
        }
    }
}

