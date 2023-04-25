//
//  ReachedTargetsView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 4/7/23.
//
// Let the user see the target prices they have already reached. User will have receive a notification for each as well.

import SwiftUI
import Firebase
import FirebaseAuth
import XCAStocksAPI

struct ReachedTargetsView: View {
    
    @State private var documents: [DocumentSnapshot] = []
    let db = Firestore.firestore()
    
    var body: some View {

        NavigationView {
            // shows existing target prices in a list
            GroupBox(label: Label("", systemImage: "dollarsign")
                .foregroundColor(Color(red: 0/255, green: 100/255, blue: 0/255))){
                    Text("Here's your  reached target prices")
                    
                    List(documents, id: \.documentID){
                        document in
                            GroupBox(label: Label(document.documentID, systemImage: "star")
                                .foregroundColor(.green)){
                                    VStack(alignment: .leading, spacing: 8) {
                                       if let document = document, document.exists,
                                          let reachedTarget = document.data()?["Reached Target"] as? Double {
                                          Spacer()
                                           Text(String(format: "Reached price %.2f", reachedTarget))
                                               .font(.headline)
                                           NavigationLink(destination: StockTickerViewPortfolio(
                                               chartVM: ChartViewModel(ticker: Ticker.init(symbol: document.documentID)),
                                               quoteVM: TickerQuoteViewModel(ticker: Ticker.init(symbol: document.documentID))
                                           )){
                                               Text("More")
                                           }
                                       }
                                }
                        }
                    }
                    .padding()
                    
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
                    
                    // gets the saved targets from database
                    .onAppear {
                        guard let uid = Auth.auth().currentUser?.uid
                        else {
                            print("user not logged in")
                            return
                        }
                        let ref = db.collection("Users").document(uid).collection("Reached Targets")
                        
                        // to show the reached target price with the symbol of the stock
                        ref.getDocuments() {
                            (querySnapshot, error) in
                            if let error = error {
                                print("Error fetching documents: \(error)")
                            }
                            else {
                                documents = querySnapshot?.documents ?? []
                            }
                        }
                    }
            }
        }
        // no back arrow
        .navigationBarBackButtonHidden(true)
    }
}

