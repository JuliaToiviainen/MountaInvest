//
//  StockTickerView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/1/23.
//
// Overall stock data View. Uses the chart, stock, data range views. Connects to database to save stocks when clicking "add to portfolio"

import SwiftUI
import XCAStocksAPI
import Firebase
import FirebaseAuth

struct StockTickerView: View {
    
    @StateObject var chartVM: ChartViewModel
    @StateObject var quoteVM: TickerQuoteViewModel
    @EnvironmentObject var appVM: AppViewModel
    @State private var documents: [DocumentSnapshot] = []
    @State var showAlertDublicate = false
    @State var showAlertAdded = false
    
    @Environment(\.dismiss) private var dismiss
    
    let db = Firestore.firestore()
    
    var body: some View {
        
        NavigationView {
            VStack(alignment: .center, spacing: 0){
                headerView.padding(.horizontal)
                
                scrollView
                Divider()
                
                VStack {
                    Text("")
                }
                .alert(isPresented: $showAlertAdded) {
                    Alert(title: Text("Succesfully Added"), message: Text("This stock is now added to your portfolio"), dismissButton: .default(Text("OK")))
                }
            }
            .padding(.top)
            .background(Color(uiColor: .systemBackground))
            .task(id: chartVM.selectedRange.rawValue) {
                if quoteVM.quote == nil {
                    await quoteVM.fetchQuote()
                }
                await chartVM.fetchData()
            }
            .toolbar{
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: HomeView()) {
                        Image(systemName: "house")
                    }
                    Spacer()
                    NavigationLink(destination: PortfolioView()) {
                        Image(systemName: "star.fill")
                    }
                    Spacer()
                    NavigationLink(destination: MainListView()) {
                        Image(systemName: "magnifyingglass")
                    }
                    Spacer()
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }

    // adding to database
    private var saveButtonView: some View {
        
        //checking if the stock symbol is already there
        Button(action: {
            
            guard let uid = Auth.auth().currentUser?.uid
            else {
                // User not logged in
                return
            }
            // adding the stock under that user
            let symbol = quoteVM.phase.value?.symbol ?? ""
            let stocks = db.collection("Users").document(uid).collection("Stocks")
            
            stocks.whereField("Symbol", isEqualTo: symbol)
              .getDocuments() { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                }
                // stocks already there
                else if !querySnapshot!.isEmpty {
                    showAlertDublicate = true
                }
                else {
                    // Add stock to database and make alert
                    stocks.document(symbol).setData(["Symbol": symbol])
                    showAlertAdded = true
                }
            }
            
        }){
          Text("Add to portfolio")
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
        .alert(isPresented: $showAlertDublicate) {
            Alert(title: Text("Already Added"), message: Text("Looks like the stock is already in your portfolio"), dismissButton: .default(Text("OK")))
        }
    }
    
    // the whole view which calls charts and date ranges and displays in a scrollview that user can scroll
    private var scrollView: some View {
        ScrollView {
            priceDiffRowView
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8)
                .padding(.horizontal)
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
                .padding()
            
            Divider()
                
            saveButtonView
            
            NavigationLink(destination: PortfolioView()){
                Text("Go to portfolio")
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
        .scrollIndicators(.hidden)
    }
    
    // shows chart view and if not able to connect it defaults to empty view
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
    
    // shows quotes and if not able to connect it defaults to empty view
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
    
    // shows price changes and if it is still trading etc.
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
    
    // displays exchange currency
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
    
    
    // shows changes and displays in red green
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
    
    // shows the stock name/symbol as a top of the view
    private var headerView: some View {
        HStack(alignment: .lastTextBaseline){
            Text(quoteVM.ticker.symbol).font(.title.bold())
            if let shortName = quoteVM.ticker.shortname {
                Text(shortName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(uiColor:.secondaryLabel))
            }
        Spacer()
        closeButton
        }
    }
    
    // X to close the header view
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Circle()
                .frame(width: 36, height: 36)
                .foregroundColor(.gray.opacity(0.2))
                .overlay {
                    Image(systemName: "xmark")
                        .font(.system(size: 18).bold())
                        .foregroundColor(Color(uiColor:.secondaryLabel))
                }
        }
        .buttonStyle(.plain)
    }
}

