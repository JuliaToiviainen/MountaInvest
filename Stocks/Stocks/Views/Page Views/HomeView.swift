//
//  HomeView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 2/22/23.
//
// Home view where user can see options they want to do next, option to go explore stocks, view own portfolio, browse reached targets
// Also accessing general counts of what we have in the database

import SwiftUI
import Firebase
import FirebaseAuth
import XCAStocksAPI

struct HomeView: View {
    
    let db = Firestore.firestore()
    @State private var countStocks = 20 // this updates from database
    @State private var documents: [DocumentSnapshot] = []
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack(alignment: .leading){
                    HStack {
                        ZStack {
                            // making random circle from the amount of stocks the user has
                            if countStocks > 0 {
                                ForEach(0..<countStocks) { index in
                                    Circle()
                                        .trim(from: CGFloat(index) / CGFloat(countStocks), to: CGFloat(index + 1) / CGFloat(countStocks))
                                        .stroke(Color(hue: Double(index) / Double(countStocks), saturation: 1.0, brightness: 1.0), lineWidth: 25)
                                        .frame(width: 150, height: 150)
                                        .rotationEffect(.degrees(-90))
                                }
                            }
                        }
                        .padding(.trailing, 10)
                        Text("Hi, welcome! \n\nIt looks like you have \(countStocks) stocks in your portfolio.")
                            .foregroundColor(.black)
                            .bold()
                            .onAppear(perform: numberOfStocks)
                            .padding(.leading, 20)
                    }
                    .padding(.leading, 50)
                    .padding()
                    
                    GroupBox(label: Label("Your portfolio\n", systemImage: "star.fill")
                        .foregroundColor(.red)){
                            Text("From here you can set and edit target prices")
                            NavigationLink(destination: PortfolioView()){
                                Text("View Portfolio")
                                    .foregroundColor(.black)
                                    .frame(width: 150, height: 30)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        }.padding()
                    // adding shadow to the box to make it look better
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
                    GroupBox(label: Label("Find new investments", systemImage: "creditcard.fill")
                        .foregroundColor(Color(red: 101/255, green: 67/255, blue: 33/255))){
                            NavigationLink(destination: MainListView()){
                                Text("Search Stocks")
                                    .foregroundColor(.black)
                                    .frame(width: 150, height: 30)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        }.padding()
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
                    GroupBox(label: Label("See your reached target prices", systemImage: "dollarsign")
                        .foregroundColor(Color(red: 0/255, green: 100/255, blue: 0/255))){
                            NavigationLink(destination: ReachedTargetsView()){
                                Text("Browse")
                                    .foregroundColor(.black)
                                    .frame(width: 150, height: 30)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                        }.padding()
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
                    GroupBox(label: Label("About MountaInvest", systemImage: "book.fill")
                        .foregroundColor(.blue)){
                            Text("\nThis app is designed to help you track your stock portfolio. Add stocks to watchlist and access more additional information that will help you achieve your financial goals.")
                                .foregroundColor(.black)
                        }.padding()
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
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
        // no back arrow
        .navigationBarBackButtonHidden(true)
    }
    
    // fetches number of stocks from database for that user
    func numberOfStocks() {
        
        guard let uid = Auth.auth().currentUser?.uid
        else {
            print("user not logged in")
            return
        }
        let ref = db.collection("Users").document(uid).collection("Stocks")
        
        ref.getDocuments() {
            (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error)")
            }
            else {
                countStocks = querySnapshot?.documents.count ?? 0
            }
        }
    }
}

