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

// MARK: - Enum for Tracing Mode
enum TracingMode {
    case trace
    case scratch
}

// MARK: - View

struct ImageListView: View {
    let categories: [Category]
    
    @State private var showGalleryPicker = false
    @State private var showCameraPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToDetail = false
    @State private var selectedMode: TracingMode = .trace
    @State private var showFullCategories = false
    @State private var selectedCategoryIndex = 0
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {

                        Picker("Mode", selection: $selectedMode) {
                            
                            Text("Trace")
                                .tag(TracingMode.trace)
                            
                            Text("Scratch")
                                .tag(TracingMode.scratch)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    
                    Text("Select Image")
                          .font(.title3)
                          .bold()
                          .frame(maxWidth: .infinity, alignment: .leading)
                          .padding(.horizontal)
                          .padding(.top, 8)
                    
                    importButtons
                        .padding(.top)
                    
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
    
    private var importButtons: some View {
        HStack(spacing: 5) {
            Button("From Gallery") {
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

// MARK: - Button Style
extension View {
    func buttonStylePrimary(color: Color) -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal, 5)
    }
}
