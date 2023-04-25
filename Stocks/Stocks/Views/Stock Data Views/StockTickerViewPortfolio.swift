//
//  StockTickerViewPortfolio.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/1/23.
//
// Overall stock data viewing from portfolio, offers possibiilty to add notes and target prices, similar to StockTickerView

import SwiftUI
import XCAStocksAPI
import Firebase
import FirebaseAuth

struct StockTickerViewPortfolio: View {
    
    @StateObject var chartVM: ChartViewModel
    @StateObject var quoteVM: TickerQuoteViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var showTargetView = false
    @State private var showNotesView = false
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            headerView.padding(.horizontal)
            Divider()
                .padding(.vertical, 8)
                .padding(.horizontal)
            scrollView
        }
        .padding(.top)
        .background(Color(uiColor: .systemBackground))
        .task(id: chartVM.selectedRange.rawValue) {
            if quoteVM.quote == nil {
                print(quoteVM)
                await quoteVM.fetchQuote()
            }
            await chartVM.fetchData()
        }
    }

    
    private var scrollView: some View {
        ScrollView {
            priceDiffRowView
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.horizontal)
            //TESTING COLOR FOR PRICE?
                .foregroundColor(.gray)
        
            Divider()
            ZStack {
                DateRangeView(selectedRange: $chartVM.selectedRange)
                    .opacity(chartVM.selectedXOpacity)
                
                Text(chartVM.selectedXDateText)
                    .font(.headline)
                    .padding(.vertical, 4)
                    .padding(.horizontal)
            }
            Divider()
                .opacity(chartVM.selectedXOpacity)
            chartView
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 220)
            
            Divider().padding([.horizontal, .top])
            
            quoteDetailRowView
                .frame(maxWidth: .infinity, minHeight: 80)
            
            Divider().padding()
            
            saveTargetView
            saveNotesView
            
        }
        .scrollIndicators(.hidden)
    }
    
    // adding to target prices to database
    private var saveTargetView: some View {
        NavigationLink(destination: TargetView(quoteVM: quoteVM)){
          Text("Modidy Targets")
            .font(.headline)
            .foregroundColor(.black)
            .padding()
            .frame(width: 200, height: 40)
            .cornerRadius(20.0)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 1)
            )
        }

    }
    
    // adding to database notes
    private var saveNotesView: some View {
        NavigationLink(destination: NotesView(quoteVM: quoteVM)){
          Text("Add Notes")
            .font(.headline)
            .foregroundColor(.black)
            .padding()
            .frame(width: 200, height: 40)
            .cornerRadius(20.0)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
    }
        
    @ViewBuilder
    private var chartView: some View {
        switch chartVM.fetchPhase {
        case .fetching: LoadingView(text: "loading")
        case .failure(let error):
            ErrorView(error: " \(error.localizedDescription)")
        case .success(let data):
            ChartView(data: data, vm: chartVM)
        default: EmptyView()
        }
    }
    
    @ViewBuilder
    private var quoteDetailRowView: some View {
        switch quoteVM.phase {
        case .fetching: LoadingView(text: "loading")
        case .failure(let error): ErrorView(error: " \(error.localizedDescription)")
                .padding(.horizontal)
        case .success(let quote):
            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(quote.colItems) {
                        StockDetailsRows(item: $0)
                    }
                }
                .padding(.horizontal)
                .font(.caption.weight(.semibold))
            }
            .scrollIndicators(.hidden)
        default: EmptyView()
        }
    }
    
    private var priceDiffRowView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let quote = quoteVM.quote {
                HStack {
                    if quote.isTrading,
                       let price = quote.regularPriceText,
                       let diff = quote.regularDiffText {
                        priceDiffStackView(price: price, diff: diff, caption: nil)
                        }
                    else {
                        if let atCloseText = quote.regularPriceText,
                           let atCloseDiffText = quote.regularDiffText {
                            priceDiffStackView(price: atCloseText, diff: atCloseDiffText, caption: "At Close")
                                .foregroundColor(.blue)
                            }
                        if let afterHourText = quote.postPriceText,
                           let afterHourDiffText = quote.postDiffText {
                            priceDiffStackView(price: afterHourText, diff: afterHourDiffText, caption: "After Hours")
                                .foregroundColor(.blue)
                            }
                    }
                    Spacer()
                }
            }
            exchangeCurrencyView
        }
    }
    
    private var exchangeCurrencyView: some View {
        HStack(spacing: 4) {
            if let exchange = quoteVM.ticker.exchDisp {
                Text(exchange)
            }
            if let currency = quoteVM.quote?.currency {
                Text("·")
                Text(currency)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundColor(Color(uiColor: .secondaryLabel))
    }
    
    
    
    private func priceDiffStackView(price: String, diff: String, caption: String?) -> some View {
       VStack(alignment: .leading) {
           HStack(alignment: .lastTextBaseline, spacing: 16) {
               Text(price).font(.headline.bold())
               Text(diff).font(.subheadline.weight(.semibold))
                   .foregroundColor(diff.hasPrefix("-") ? .red : .green)
           }
           
           if let caption {
               Text(caption)
                   .font(.subheadline.weight(.semibold))
                   .foregroundColor(Color(uiColor: .secondaryLabel))
           }
       }
    }
    
    private var headerView: some View {
        HStack(alignment: .lastTextBaseline){
            Text(quoteVM.ticker.symbol).font(.title.bold())
            if let shortName = quoteVM.ticker.shortname {
                Text(shortName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor:.secondaryLabel))
            }
        Spacer()
        }
    }
}
