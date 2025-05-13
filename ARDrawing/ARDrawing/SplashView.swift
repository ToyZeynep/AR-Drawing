//
//  SplashView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 13.05.2025.
//


import SwiftUI
import SDWebImageSwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var categories: [Category] = []
    
    var body: some View {
        if isActive {
            ImageListView(categories: categories)
        } else {
            ZStack {
                // 🔵 Arka plan
                Color(red: 203/255, green: 237/255, blue: 253/255)
                    .ignoresSafeArea()

                // 🎞 GIF içeriği
                AnimatedImage(name: "splash.gif")
                    .resizable()
                    .scaledToFit()
                    .background(Color(red: 203/255, green: 237/255, blue: 253/255))
            }
            .onAppear {
                fetchImageList { fetched in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.categories = fetched
                        self.isActive = true
                    }
                }
            }
        }
    }
    
    func fetchImageList(completion: @escaping ([Category]) -> Void) {
        guard let url = URL(string: "https://toyzeynep.github.io/line-art-api/images.json") else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ImageListResponse.self, from: data)
                completion(decoded.categories)
            } catch {
                print("JSON decoding error: \(error)")
                completion([])
            }
        }.resume()
    }
}
