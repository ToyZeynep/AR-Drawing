//
//  ARDrawingApp.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 10.05.2025.
//

import SwiftUI
import Firebase
 
@main
struct ARDrawingApp: App {

    init() {
        FirebaseApp.configure()
        
    #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(true)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
