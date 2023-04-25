//
//  StocksApp.swift
//  Stocks
//
//  Created by Julia Toiviainen on 1/5/23.
//
// The core of the app starts from here, confuguration to firebase and to user nofitications and connected to appViewModel object

import SwiftUI
import FirebaseCore
import Firebase
import FirebaseAuth
import UserNotifications

@main
struct StocksApp: App {
    
    @StateObject var appVM = AppViewModel()
    
    init() {
        //make connection to firebase
        FirebaseApp.configure()
        
        // user notifications
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]){
            (granted, error) in
        }
    }
    
    // starts by Welcome view
    var body: some Scene {
         WindowGroup {
             NavigationStack {
                 WelcomeView()
             }
             .environmentObject(appVM)
         }
    }
}
