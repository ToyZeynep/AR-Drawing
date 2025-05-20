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

enum TracingMode {
    case trace
    case scratch
}

struct ImageListView: View {
    let categories: [Category]
    
    @State private var showGalleryPicker = false
    @State private var showCameraPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToDetail = false
    @State private var selectedMode: TracingMode = .trace
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    
                    Text("Drawing Mode")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 12)
                    
                    tracingModeButtons
                        .padding(.top, 4)
                    
                    Text("Import from")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)

                    actionButtons
                        .padding(.top)

                    Text("Choose a topic")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    ForEach(categories) { category in
                        categorySection(for: category)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("TraceCam")
            .sheet(isPresented: $showGalleryPicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear { handleImageSelection() }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $selectedImage)
                    .onDisappear { handleImageSelection() }
            }
            .background(
                NavigationLink(destination: DetailView(imageURL: nil, selectedUIImage: selectedImage, tracingMode: selectedMode),
                               isActive: $navigateToDetail) {
                                   EmptyView()
                               }
                    .hidden()
            )
        }
    }
    
    private var tracingModeButtons: some View {
        HStack(spacing: 8) {
            Button("Trace") {
                selectedMode = .trace
            }
            .buttonStylePrimary(color: selectedMode == .trace ? .blue : .gray)
            
            Button("Scratch") {
                selectedMode = .scratch
            }
            .buttonStylePrimary(color: selectedMode == .scratch ? .blue : .gray)
        }
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 5) {
            Button("Select from Gallery") {
                showGalleryPicker = true
            }
            .buttonStylePrimary(color: .blue)
            
            Button("Take Photo") {
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
                    NavigationLink(destination: DetailView(imageURL: url, tracingMode: selectedMode)) {
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
    
    private func handleImageSelection() {
        if selectedImage != nil {
            navigateToDetail = true
        }
    }
}
