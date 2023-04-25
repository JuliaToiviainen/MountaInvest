//
//  PortfolioView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/28/23.
//
//This view provides the user's own portfolio view. It fetches data from Yahoo using the stocks that had been added to the database under current user

import SwiftUI
import XCAStocksAPI
import Firebase
import FirebaseAuth

struct PortfolioView: View {
    
    @State private var documents: [DocumentSnapshot] = []
    @StateObject var quotesVM = QuotesViewModel()
    @StateObject var searchVM = SearchViewModel()
    @EnvironmentObject var appVM: AppViewModel
    let db = Firestore.firestore()
    @State private var showAlert = false
    @State private var timer: Timer?
    @State private var currentStock = ""
    
    var body: some View {
        
        NavigationView{
            VStack(alignment: .leading){
                
                GroupBox(label: Label("", systemImage: "star.fill")
                    .foregroundColor(.red)){
                        Text("Welcome to your portfolio.\nHere's your current stocks.")
                        
                    }.padding()
                
                //creating a list of stocks that are saved to database
                List(documents, id: \.documentID) {
                    document in if let name = document.data()?["Symbol"] as? String {
                        GroupBox(label: Label(name, systemImage: "star")
                            .foregroundColor(.black)){
                                NavigationLink(destination: StockTickerViewPortfolio(chartVM: ChartViewModel(ticker: Ticker.init(symbol: name)), quoteVM: TickerQuoteViewModel(ticker: Ticker.init(symbol: name)))){
                                    HStack{
                                        Text("More")
                                        .foregroundColor(.blue)
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Button(action: {
                                            currentStock = name
                                            showAlert = true
                                        }) {
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        // adding shadow?
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Are you sure you want to delete"),
                                message: Text("Once deleted all data under the stock will be deleted too"),
                                primaryButton: .default(Text("Yes"), action: {
                                    print(currentStock)
                                    removeStock(currentStock)
                                }),
                                secondaryButton: .cancel(Text("No"))
                            )
                        }
                        .foregroundColor(.red)
                    }
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
            //checking all the time if edits to portfolio
            .onAppear {
                checkPortfolio()
                timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    checkPortfolio()
                }
            }
        }
        // no back arrow
        .navigationBarBackButtonHidden(true)
    }
        
    private func removeStock(_ stock: String) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("user not logged in")
            return
        }
        
        db.collection("Users").document(uid).collection("Stocks").document(stock).delete(){
            error in if let error = error {
                print("Error removing stock: \(error.localizedDescription)")
            }
            else {
                print("Stock removed successfully")
            }
        }
    }
    
    // check what's in it
    func checkPortfolio(){
        guard let uid = Auth.auth().currentUser?.uid else {
            print("user not logged in")
            return
        }
        let ref = db.collection("Users").document(uid).collection("Stocks")
        
        ref.getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            }
            else {
                documents = querySnapshot?.documents ?? []
            }
        }
    }
}
        
