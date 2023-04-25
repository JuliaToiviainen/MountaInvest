//
//  TargetView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 3/15/23.
//
// This view will be where the user can edit an add target prices, it will send notifications based on the targets

import SwiftUI
import Firebase
import FirebaseAuth
import XCAStocksAPI
import UserNotifications

struct TargetView: View {
    
    @State private var targetPrice = Double("")
    @State private var savedTargets: [Double] = []
    @State private var reachedTargets: [Double] = []
    @State private var isTargetPriceReached = false
    let db = Firestore.firestore()
    @State private var documents: [DocumentSnapshot] = []
    @StateObject var quoteVM: TickerQuoteViewModel
    @State private var timer: Timer?
    @State private var selling = false
    @State private var buying = false
    @State private var alert = false // alert for buying or selling
    
    var body: some View {
        
        NavigationView {
        VStack(alignment: .leading){
            
            GroupBox(label: Label("", systemImage: "dollarsign")
                .foregroundColor(.green)){
                    Text("Add a target price\n\nYou will receive notifications once it is reached")
                    Divider()
                    TextField("Add price..", value: self.$targetPrice, format: .number)
                        .padding()
                        .cornerRadius(20.0)
                    
                saveButtonView
                    
                //alert with option you want to sell or buy, this will affect the notifications of target prices
                .alert(isPresented: $alert) {
                        Alert(
                            title: Text("Buying or Selling"),
                            message: Text("Please indicate are you planning to buy or sell"),
                            primaryButton: .default(
                                Text("Buy"),
                                action: {
                                    buying = true
                                   // selling = false
                                }
                            ),
                            secondaryButton: .default(
                                Text("Sell"),
                                action: {
                                    selling = true
                                   // buying = false
                                }
                            )
                        )
                    }
                    
            }.padding()
            .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
            
            // shows existing target prices in 2 decimal accurancy
            GroupBox(label: Label("Your target prices:", systemImage: "dollarsign")
                .foregroundColor(.green)){

                    List(savedTargets, id: \.self) { target in
                        Text(String(format: "%.2f", target))
                        Button(action: {
                            removeTargets(target)
                        }) {
                            Image(systemName: "trash")
                        }
                        .foregroundColor(.red)
                    }
                    .padding()
                    .cornerRadius(20.0)
            }
            .padding()
            .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
            
            // gets the saved targets from database
            .onAppear {
                guard let uid = Auth.auth().currentUser?.uid
                else {
                    print("user not logged in")
                    return
                }
                let ref = db.collection("Users").document(uid).collection("Stocks")
                
                ref.whereField("Symbol", isEqualTo: quoteVM.phase.value!.symbol).getDocuments() {
                    (querySnapshot, error) in
                    if let error = error {
                        print("Error fetching documents: \(error)")
                    } else {
                        documents = querySnapshot?.documents ?? []
                        if let targetsArray = documents.first?.data()!["Targets"] as? [Double] {
                                savedTargets = targetsArray
                        }
                    }
                }
            }
        }
        //having timer to check if target price is reached every 5 seconds
        .onAppear {
                timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                    checkTargetPrices()
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
    
    //saves target price for that specific stock to the database
    private var saveButtonView: some View {
        // alert when button clicked about buying or selling
        Button(action: {
            alert = true
            guard let uid = Auth.auth().currentUser?.uid
            else {
                print("user not logged in")
                return
            }
            
            db.collection("Users").document(uid).collection("Stocks").document(quoteVM.phase.value!.symbol).updateData(["Targets": FieldValue.arrayUnion([targetPrice as Any])])
            
            savedTargets.append(targetPrice!)
            //print(savedTargets)
            
        }){
            Text("Update target price")
                .foregroundColor(.white)
                .frame(width: 200, height: 40)
                .background(Color.green)
                .cornerRadius(20)
        }
    }
    // removing target from the list
    private func removeTargets(_ target: Double) {
        
        guard let uid = Auth.auth().currentUser?.uid
        else {
            print("user not logged in")
            return
        }
        let ref = db.collection("Users").document(uid).collection("Stocks").document(quoteVM.phase.value!.symbol)
        
        ref.updateData(["Targets": FieldValue.arrayRemove([target])]) {
            error in if let error = error {
                print("Error removing target price: \(error.localizedDescription)")
            }
            else {
                print("Target price removed successfully")
                self.savedTargets.removeAll(where: { $0 == target })
            }
        }
    }
    
    //looping through saved target prices and checking if they're reached depending is user selling or buying
    private func checkTargetPrices() {
        guard let uid = Auth.auth().currentUser?.uid
        else {
            print("user not logged in")
            return
        }
        for target in savedTargets {
            //if quoteVM.phase.value?.regularMarketPrice == target{
            if let regularMarketPrice = quoteVM.phase.value?.regularMarketPrice, abs(regularMarketPrice - target) <= 0.50 {

                let content = UNMutableNotificationContent()
                content.title = "Target price reached!"
                content.body = "for \(quoteVM.phase.value!.symbol): \(target)"
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) {
                    error in if let error = error {
                        print("Error adding notification request: \(error.localizedDescription)")
                    }
                    else {
                        print("Notification request added successfully")
                    }
                }
                
                //add it to reached targets and remove from saved targers
                db.collection("Users").document(uid).collection("Reached Targets").document(quoteVM.phase.value!.symbol).setData(["Reached Target": targetPrice as Any], merge: true)
                
                //reachedTargets.append(target)
                db.collection("Users").document(uid).collection("Stocks").document(quoteVM.phase.value!.symbol).updateData(["Targets": FieldValue.arrayRemove([target])]) {
                    error in if let error = error {
                        print("Error removing target price: \(error.localizedDescription)")
                    }
                    else {
                        print("Target price removed successfully")
                        self.savedTargets.removeAll(where: { $0 == target })
                    }

                }
            }
        }
    }
}

