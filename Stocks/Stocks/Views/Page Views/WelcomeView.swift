//
//  WelcomeView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/31/23.
//
// Basic view to welcome users and let's user to log in or create user. It checks constantly if user is logged in or not and displays correct buttons based on that

import SwiftUI
import FirebaseAuth

struct WelcomeView: View {
    
    @State var loggedIn = false
    @State var loggedOut = false
    @State private var timer: Timer?
    
    var body: some View {
        
        ZStack{
            Color.white
            .ignoresSafeArea()
            NavigationView {
                ZStack() {
                    Image("MountaInvest")
                        .resizable()
                        .opacity(0.4)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 5000, height: 500)
                        .position(CGPoint(x: 190, y: 300))
                    
                    //if user is logged, shows buttons: log out and home else, shows buttons: sign in and create account
                    VStack(){
                        if loggedIn {
                            NavigationLink(destination: HomeView()){
                                Text("Home")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 300, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                            Button(action: {
                                try! Auth.auth().signOut()
                                loggedIn = false
                            }){
                                Text("Log Out")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(width: 300, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            }
                        }
                        else if loggedOut {
                            NavigationLink(destination: SignInView()){
                                Text("Sign In")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 300, height: 50)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                                
                            }
                            
                            NavigationLink(destination: CreateAccountView()){
                                Text("Create account")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding()
                                    .frame(width: 300, height: 50)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                            }
                        }
                    }.position(CGPoint(x: 200, y: 650))
                }
                // doesnt go to dark mode as background picture is white
                .preferredColorScheme(.light)
                .opacity(0.9)
                // this is checking if there's user logged in so we know which buttons to show once the user opens the screen
                .onAppear {
                    print("HomeView appeared")
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            loggedIn = true
                            loggedOut = false
                        }
                        else{
                            print("logged out")
                            loggedOut = true
                            loggedIn = false
                        }
                    }
                }
            }
        }
    }
}

