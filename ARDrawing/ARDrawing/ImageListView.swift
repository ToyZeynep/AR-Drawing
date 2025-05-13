//
//  ImageListView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 10.05.2025.
//


import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

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

// MARK: - View

struct ImageListView: View {
    let categories: [Category]

    @State private var showGalleryPicker = false
    @State private var showCameraPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToDetail = false

    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    actionButtons
                        .padding(.top)

                    ForEach(categories) { category in
                        categorySection(for: category)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("Boyama Görselleri")
            .sheet(isPresented: $showGalleryPicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear { handleImageSelection() }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $selectedImage)
                    .onDisappear { handleImageSelection() }
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

    // MARK: - Alt Görünümler

    private var actionButtons: some View {
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
    }

    @ViewBuilder
    private func categorySection(for category: Category) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.name)
                .font(.headline)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(category.images, id: \.self) { url in
                    NavigationLink(destination: DetailView(imageURL: url)) {
                        WebImage(url: URL(string: url))
                            .resizable()
                            .indicator(.activity)
                            .transition(.fade(duration: 0.3))
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

    // MARK: - Yardımcı Fonksiyonlar

    private func handleImageSelection() {
        if selectedImage != nil {
            navigateToDetail = true
        }
    }
}
