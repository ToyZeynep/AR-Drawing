//
//  ImageListView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 10.05.2025.
//


import SwiftUI
import PhotosUI
import Kingfisher

// MARK: - Model
struct Category: Codable, Identifiable {
    var id: UUID { UUID() }
    let name: String
    let images: [String]
    
    private enum CodingKeys: String, CodingKey {
        case name, images
    }
}

struct ImageListResponse: Codable {
    let categories: [Category]
}

struct ImageListView: View {
    @State private var categories: [Category] = []
    @State private var isLoading = true
    
    @State private var showGalleryPicker = false
    @State private var showCameraPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToDetail = false

    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    // 📸 Butonlar
                    HStack(spacing: 12) {
                        Button("Galeriden Seç") {
                            showGalleryPicker = true
                        }
                        .buttonStylePrimary(color: .blue)

                        Button("Kamera ile Çek") {
                            showCameraPicker = true
                        }
                        .buttonStylePrimary(color: .green)
                    }
                    .padding(.top)

                    // 🔄 Yükleme durumu
                    if isLoading {
                        ProgressView("Yükleniyor...")
                            .padding()
                    } else {
                        // 📦 Kategori listesi
                        ForEach(categories) { category in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category.name)
                                    .font(.headline)
                                    .padding(.horizontal)

                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(category.images, id: \.self) { url in
                                        NavigationLink(destination: DetailView(imageURL: url)) {
                                            KFImage(URL(string: url))
                                                .resizable()
                                                .placeholder {
                                                    ProgressView()
                                                        .frame(width: 100, height: 100)
                                                }
                                                .cancelOnDisappear(true)
                                                .scaledToFill()
                                                .frame(width: 100, height: 100)
                                                .clipped()
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle("Boyama Görselleri")
            .onAppear {
                fetchImageList { fetched in
                    DispatchQueue.main.async {
                        self.categories = fetched
                        self.isLoading = false
                    }
                }
            }
            .sheet(isPresented: $showGalleryPicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            navigateToDetail = true
                        }
                    }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            navigateToDetail = true
                        }
                    }
            }
            .background(
                NavigationLink(destination: DetailView(imageURL: nil, selectedUIImage: selectedImage),
                               isActive: $navigateToDetail) {
                    EmptyView()
                }
                .hidden()
            )
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
