//
//  CreateAccountView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 3/18/23.
//
// account sign in view

import SwiftUI
import Firebase
import FirebaseAuth

struct SignInView: View {
    
    let db = Firestore.firestore()
    @State private var email = ""
    @State private var password = ""
    @State private var loggedIn = false
    @State var showAlertLoggedIn = false
    @State var showAlertForgotPassword = false
    @State var showAlertIncorrectCredentials = false
    @State var homeView = false
    @State var forgotpassword = false
    @State var showForm = false
    @State private var alertMessage = ""
    
    @Environment(\.dismiss) private var dismiss
          
    var body: some View {
        ZStack() {
            Image("MountaInvest")
            .resizable()
            .opacity(0.4)
            .aspectRatio(contentMode: .fit)
            .frame(width: 5000, height: 550)
            .position(CGPoint(x: 190, y: 300))
        VStack() {
            Text("MountaInvest")
                  .padding()
                  .font(Font.largeTitle)
                  .padding()
            
            VStack(alignment: .leading, spacing: 20) {
              TextField("Email", text: self.$email)
                .padding()
                .cornerRadius(20.0)
                            
              SecureField("Password", text: self.$password)
                .padding()
                .cornerRadius(20.0)
            }
            .padding([.leading, .trailing], 30)
            .padding()
            
            Button{
                signIn()
            }
            label:{
                Text("Sign In")
                  .font(.headline)
                  .foregroundColor(.white)
                  .padding()
                  .frame(width: 300, height: 50)
                  .background(Color.blue)
                  .cornerRadius(20)
            }
            .onAppear{
                Auth.auth().addStateDidChangeListener {
                    auth, user in if user != nil {
                        loggedIn.toggle()
                    }
                }
            }
            // alert if incorrect email or password
            .alert(isPresented: $showAlertIncorrectCredentials) {
                Alert(title: Text("Incorrect email or password"), message: Text("Please try again"),
                      dismissButton: Alert.Button.default(
                        Text("Try again"), action: {
                            showAlertIncorrectCredentials = false
                        }
                      )
                )
            }
            
            Button(action: {
                try! Auth.auth().signOut()
                showForm = true
            }){
                Text("Forgot my password")
                    .font(.body)
                    .underline()
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: 300, height: 50)
                    .cornerRadius(20.0)
            }
            .fullScreenCover(isPresented: $homeView, content: {
                HomeView()
            })
            .alert(isPresented: $showAlertForgotPassword) {
                Alert(title: Text("Thank you!"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .padding()
            
            
        }
        .background(.white)
        .opacity(0.8)
        .cornerRadius(20)
        .padding()
        // no dark mode
        .preferredColorScheme(.light)

            
        VStack{
            // alert if user logged back in
            Text("")
            .alert(isPresented: $showAlertLoggedIn) {
                Alert(title: Text("Welcome back"), message: Text("You're logged in succesfully"),
                      dismissButton: Alert.Button.default(
                        Text("Home"), action: {
                            homeView.toggle()
                        }
                      )
                )
            }
            if showForm {
                    Form {
                        Section(header: Text("Email")) {
                            TextField("Enter your email", text: $email)
                                .autocapitalization(.none)
                        }
                        Button (action: {
                            forgotPassword()
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
        }
    }
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                showAlertIncorrectCredentials = true
            }
            else {
                print("username sign in succesfully")
                showAlertLoggedIn = true
            }
        }
    }
    
    func forgotPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error with sending link to reset password: \(error.localizedDescription)")
                alertMessage = "But we had an error sending the reset link"
                showAlertForgotPassword = true
            } else {
                print("Email sent to reset password")
                alertMessage = "Reset link has been sent to your email!"
                showAlertForgotPassword = true
            }
        }
    }
}

