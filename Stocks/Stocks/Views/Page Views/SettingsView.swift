//
//  SettingsView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 4/6/23.
//
// Settings view with different functionalities, delete user, contact, reset password and log out

import SwiftUI
import FirebaseAuth
import Firebase
import MessageUI

struct SettingsView: View {
    
    @State var showAlertDelete = false
    @State var welcomeView = false
    @State var readyToExit = false
    @State private var email = ""
    @State var showForm = false
    @State private var alertMessage = ""
    @State var showAlertPassword = false
    
    var body: some View {
        // form to show if user wants to send email to organization
        ZStack{
            if showForm {
                Form {
                    Section(header: Text("Email")) {
                        TextField("Enter your email", text: $email)
                            .autocapitalization(.none)
                    }
                    
                    Button (action: {
                        Auth.auth().sendPasswordReset(withEmail: email) { error in
                            if let error = error {
                                print("Error with sending link to reset password: \(error.localizedDescription)")
                                alertMessage = "But we had an error sending the reset link"
                                showAlertPassword = true
                            }
                            else {
                                print("Email sent to reset password")
                                alertMessage = "Reset link has been sent to your email!"
                                showAlertPassword = true
                            }
                        }
                    }){
                        Text("Send link")
                            .foregroundColor(.black)
                            .frame(width: 300, height: 40)
                    }
                    // button to close the form
                    Button(action: {
                        showForm = false
                    }) {
                        Text("Close form")
                            .foregroundColor(.black)
                            .frame(width: 300, height: 40)
                    }
                }
            }
        }
       // .background(.white)
        
        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing:-4){
                    
                    // Logging Out
                    GroupBox(label: Label("Log Out\n", systemImage: "gear")
                        .foregroundColor(.black)){
                            Text("Don't worry everything is saved!")
                            Button(action: {
                                try! Auth.auth().signOut()
                                readyToExit = true
                            }){
                                Text("Log Out")
                                    .foregroundColor(.red)
                                    .padding()
                                    .frame(width: 150, height: 40)
                                    .cornerRadius(15.0)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.red, lineWidth: 1)
                                    )
                            }
                            .alert(isPresented: $readyToExit) {
                                Alert(title: Text("Thank you!"),
                                      dismissButton: Alert.Button.default(
                                        Text("Exit"), action: {
                                            welcomeView = true
                                            readyToExit = false
                                        }
                                      )
                                )
                            }
                        }
                        .padding()
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
                    // Contacting, it will send and email to my email
                    GroupBox(label: Label("Contact Us\n", systemImage: "mail")
                        .foregroundColor(.black)){
                            Text("We would love to hear feedback. \nPlease let us know how to improve MountaInvest.")
                            Button(action: {
                                emailRequest()
                            }) {
                                Text("Send Us Email")
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: 150, height: 40)
                                    .cornerRadius(15.0)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                            
                        }
                        .padding()
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
                    //to reset password by getting new link
                    GroupBox(label: Label("Change Password\n", systemImage: "lock")
                        .foregroundColor(.black)){
                            Text("We'll send you a link to reset your password to your email. You'll be automatically logged out.")
                            Button(action: {
                                showForm = true
                            }){
                                Text("Request link")
                                .foregroundColor(.black)
                                .padding()
                                .frame(width: 150, height: 40)
                                .cornerRadius(15.0)
                                .overlay(
                                 RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                                 )
                            }
                            .alert(isPresented: $showAlertPassword) {
                                Alert(title: Text(alertMessage),
                                    dismissButton: Alert.Button.default(Text("Thank You!"), action: {
                                          try! Auth.auth().signOut()
                                          welcomeView = true
                                      })
                                )
                            }
                            .padding()
                            
                        }
                    .padding()
                    .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
                    
                    GroupBox(label: Label("Delete user\n", systemImage: "trash")
                        .foregroundColor(.black)){
                            Text("I'm sorry to hear you want to delete your user.")
                            Button(action: {
                                showAlertDelete = true
                            }) {
                                Text("Delete Account")
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: 150, height: 40)
                                    .cornerRadius(15.0)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            }
                            .alert(isPresented: $showAlertDelete) {
                                Alert(
                                    title: Text("Are you sure you want to delete user"),
                                    message: Text("Once deleted all data under the user will be deleted."),
                                    primaryButton: .default(Text("Yes"), action: {
                                        removeUser()
                                        try! Auth.auth().signOut()
                                        welcomeView = true
                                    }),
                                    secondaryButton: .cancel(Text("No"), action: {
                                        showAlertDelete = false
                                    })
                                )
                            }
                        }
                        .padding()
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
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
                .fullScreenCover(isPresented: $welcomeView, content: {
                    WelcomeView()
                })
            }
        }
        // no back arrow
        .navigationBarBackButtonHidden(true)
    }
}

// send email to mountaInvest
func emailRequest(){
    if let url = URL(string: "mailto:mountainvest@info.com?subject=MountaInvest%20Feedback&body=Please%20write%20some%20feedback!") {
        UIApplication.shared.open(url)
    }
}

//removing user from the database with their data
private func removeUser() {
    
    guard let user = Auth.auth().currentUser?.uid
    else {
        print("User not found")
        return
    }
    let refStocks = Firestore.firestore().collection("Users/\(user)/Stocks")
    let refTargets = Firestore.firestore().collection("Users/\(user)/Reached Targets")
        
    let batch = Firestore.firestore().batch()
        
    // deleting stocks under user
    refStocks.getDocuments() { querySnapshot, error in
        if let error = error {
            print("Error getting documents: \(error)")
        } else {
            let batch = Firestore.firestore().batch()
            for document in querySnapshot!.documents {
                batch.deleteDocument(document.reference)
            }
                
            batch.commit() { error in
                if let error = error {
                    print("Error deleting stocks: \(error)")
                } else {
                    print("Stocks deleted successfully.")
                }
            }
        }
    }
// deleting reached targets under user
    refTargets.getDocuments() { querySnapshot, error in
        if let error = error {
            print("Error getting documents: \(error)")
        } else {
            let batch = Firestore.firestore().batch()
            for document in querySnapshot!.documents {
                batch.deleteDocument(document.reference)
            }
                
            batch.commit() { error in
                if let error = error {
                    print("Error deleting targets: \(error)")
                } else {
                    print("Reached targets deleted successfully.")
                }
            }
        }
    }
    //and lastly deleting the user
    Firestore.firestore().collection("Users").document(user).delete() {
        error in if let error = error {
            print("Error deleting user: \(error)")
        } else {
            print("User deleted successfully.")
        }
    }
}


