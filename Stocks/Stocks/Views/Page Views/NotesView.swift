//
//  NotesView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 3/14/23.
//

import SwiftUI
import Firebase
import XCAStocksAPI
import FirebaseAuth

struct NotesView: View {
    
    @State private var notes = ""
    @State private var savedNotes: [String] = []
    let db = Firestore.firestore()
    @State private var documents: [DocumentSnapshot] = []
    @StateObject var quoteVM: TickerQuoteViewModel
    
    var body: some View {
        NavigationView {
        VStack(alignment: .leading){
            
            GroupBox(label: Label("", systemImage: "book.fill")
                .foregroundColor(.red)){
                    Text("Write notes to yourself to view later")
                    Divider()
                    TextField("Write here...", text: self.$notes)
                        .padding()
                        .cornerRadius(20.0)
                    
                    saveButtonView
                    
                }.padding()
                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
            
            GroupBox(label: Label("Your notes:", systemImage: "book.fill")
                .foregroundColor(.red)){
                    List(savedNotes, id: \.self) { note in
                        Text(note)
                        Button(action: {
                            removeNotes(note)
                        }) {
                            Image(systemName: "trash")
                        }
                        .foregroundColor(.red)
                    }
                }
                .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
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
                            if let notesArray = documents.first?.data()!["Notes"] as? [String] {
                                savedNotes = notesArray
                            }
                        }
                    }
                }
                .padding()
                .cornerRadius(20.0)
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
        .padding()
    }
}
    
    // adding to database under that speficic stock that is selected
    private var saveButtonView: some View {
        Button(action: {
            guard let uid = Auth.auth().currentUser?.uid
            else {
                print("user not logged in")
                return
            }
            db.collection("Users").document(uid).collection("Stocks").document(quoteVM.phase.value!.symbol).updateData(["Notes": FieldValue.arrayUnion([notes])])
            
            savedNotes.append(notes)
                                                      
        }){
            Text("Add notes")
                .foregroundColor(.white)
                .frame(width: 200, height: 40)
                .background(Color.green)
                .cornerRadius(20)
        }
    }
    private func removeNotes(_ note: String) {
        guard let uid = Auth.auth().currentUser?.uid
        else {
            print("user not logged in")
            return
        }
        let ref = db.collection("Users").document(uid).collection("Stocks").document(quoteVM.phase.value!.symbol)
        
        ref.updateData(["Notes": FieldValue.arrayRemove([note])]) {
            error in if let error = error {
                print("Error removing note: \(error.localizedDescription)")
            }
            else {
                print("Note removed successfully")
                self.savedNotes.removeAll(where: { $0 == note })
            }
        }
    }
}

