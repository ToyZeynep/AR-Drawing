//
//  ImageListView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 10.05.2025.
//


import SwiftUI

struct ImageListView: View {
    @State private var imageURLs: [String] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Yükleniyor...")
                } else {
                    List(imageURLs, id: \.self) { url in
                        NavigationLink(destination: DetailView(imageURL: url)) {
                            AsyncImage(url: URL(string: url)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 120)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Boyama Görselleri")
            .onAppear {
                fetchImageList { urls in
                    self.imageURLs = urls
                    self.isLoading = false
                }
            }
        }
    }

    struct ImageList: Codable {
        let images: [String]
    }

    func fetchImageList(completion: @escaping ([String]) -> Void) {
        let urlString = "https://toyzeynep.github.io/line-art-api/images.json"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }

            print(String(data: data, encoding: .utf8) ?? "Veri okunamadı")

            do {
                let decoded = try JSONDecoder().decode(ImageList.self, from: data)
                completion(decoded.images)
            } catch {
                print("JSON decoding error: \(error)")
                completion([])
            }
        }.resume()
    }

}

struct ImageList: Codable {
    let images: [String]
}
