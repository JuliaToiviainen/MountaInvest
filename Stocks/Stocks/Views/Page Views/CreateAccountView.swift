//
//  CreateAccountView.swift
//  Stocks
//
//  Created by Julia Toiviainen on 3/18/23.
//
// Account creation view with multiple pop up window. Checks if email and password are valid informs user about necessary changes.

import SwiftUI
import Firebase
import FirebaseAuth

struct CreateAccountView: View {
    
    let db = Firestore.firestore()
    @State private var email = ""
    @State private var password = ""
    @State private var loggedIn = false
    @State var showAlertCreated = false
    @State var homeView = false
    @State var showAlertCredentials = false

          
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
                }.padding([.leading, .trailing], 30)
                    .padding()
                
                Button{
                    createUser()
                }
            label:{
                Text("Create account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(20.0)
            }
            .onAppear{
                Auth.auth().addStateDidChangeListener {
                    auth, user in if user != nil {
                        loggedIn.toggle()
                    }
                }
            }
            // successfully created
            .alert(isPresented: $showAlertCreated) {
                Alert(title: Text("Welcome!"), message: Text("User created succesfully"),
                      dismissButton: Alert.Button.default(
                        Text("Home"), action: {
                            homeView.toggle()
                        }
                      )
                )
            }
                VStack{
                    Text("")
                    // invalid email or password
                        .alert(isPresented: $showAlertCredentials) {
                            Alert(title: Text("Please check!"), message: Text("Email has to be valid email format and password must be at least 6 characters long"),
                                  dismissButton: .default(Text("Ok"))
                            )
                        }
                }
                .fullScreenCover(isPresented: $homeView, content: {
                    HomeView()
                })
            }
            .background(.white)
            .opacity(0.8)
            .cornerRadius(20)
            .padding()
            // no dark mode
            .preferredColorScheme(.light)
        }
    }
    
    // saves user to database
    func createUser() {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                showAlertCredentials = true
            }
            else {
                print("username created succesfully and logged in")
                showAlertCreated = true
            }
        }
    }
}

