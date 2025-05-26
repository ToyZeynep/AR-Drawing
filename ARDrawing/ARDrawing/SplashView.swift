//
//  SplashView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 13.05.2025.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct SplashView: View {
    @State private var isActive = false
    @State private var isInitialized = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        if isActive {
            CategoriesHomeView()
                .preferredColorScheme(.light)
        } else {
            ZStack {
                Color(red: 203/255, green: 237/255, blue: 253/255)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    AnimatedImage(name: "splash.gif")
                        .resizable()
                        .scaledToFit()
                        .background(Color(red: 203/255, green: 237/255, blue: 253/255))
                    
                    if showError {
                        VStack(spacing: 12) {
                            Text("Connection Error")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Button("Retry") {
                                showError = false
                                initializeApp()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    } else if !isInitialized {
                        VStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.2)
                            
                            Text("Initializing...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .onAppear {
                initializeApp()
            }
        }
    }
    
    private func initializeApp() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        testFirebaseConnection { success, error in
            DispatchQueue.main.async {
                if success {
                    self.isInitialized = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.isActive = true
                        }
                    }
                } else {
                    self.showError = true
                    self.errorMessage = error ?? "Failed to connect to server"
                }
            }
        }
    }
    
    private func testFirebaseConnection(completion: @escaping (Bool, String?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("categories").limit(to: 1).getDocuments { snapshot, error in
            if let error = error {
                completion(false, "Connection failed: \(error.localizedDescription)")
            } else {
                completion(true, nil)
            }
        }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
