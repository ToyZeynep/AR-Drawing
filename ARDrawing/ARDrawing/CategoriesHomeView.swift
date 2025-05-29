//
//  CategoriesHomeView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 26.05.2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import SDWebImageSwiftUI

// MARK: - Models

struct Category: Codable, Identifiable {
    let id: String
    let name: String
    let order: Int
    let isActive: Bool
    let images: [String]
    
    var uiId: UUID { UUID() }
}

enum TracingMode {
    case trace
    case scratch
}
    
struct CategoryPreview: Codable, Identifiable {
    let id: String
    let name: String
    let order: Int
    let isActive: Bool
    let imageCount: Int
    let previewImage: String
    
    var uiId: UUID { UUID() }
}

// MARK: - Firebase Service

class CategoryService: ObservableObject {
    @Published var categories: [CategoryPreview] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchCategories() {
        isLoading = true
        errorMessage = nil
        
        db.collection("categories")
            .order(by: "order")
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self?.errorMessage = "No active categories found"
                        return
                    }
                    
                    self?.categories = documents.compactMap { doc in
                        let data = doc.data()
                        guard let name = data["name"] as? String,
                              let order = data["order"] as? Int,
                              let isActive = data["isActive"] as? Bool,
                              let images = data["images"] as? [String],
                              !images.isEmpty,
                              isActive == true else { return nil }
                        
                        return CategoryPreview(
                            id: doc.documentID,
                            name: name,
                            order: order,
                            isActive: isActive,
                            imageCount: images.count,
                            previewImage: images.first ?? ""
                        )
                    }

                    if self?.categories.isEmpty == true {
                        self?.errorMessage = "No active categories available at the moment"
                    }
                }
            }
    }
    
    func fetchCategoryDetail(categoryId: String, completion: @escaping (Category?) -> Void) {
        db.collection("categories").document(categoryId).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching category: \(error)")
                completion(nil)
                return
            }
            
            guard let data = snapshot?.data(),
                  let name = data["name"] as? String,
                  let order = data["order"] as? Int,
                  let isActive = data["isActive"] as? Bool,
                  let images = data["images"] as? [String],
                  isActive == true else {
                completion(nil)
                return
            }
            
            let category = Category(
                id: categoryId,
                name: name,
                order: order,
                isActive: isActive,
                images: images
            )
            completion(category)
        }
    }
}

// MARK: - Categories Home View

struct CategoriesHomeView: View {
    @StateObject private var categoryService = CategoryService()
    @State private var showGalleryPicker = false
    @State private var showCameraPicker = false
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToARView = false
    @State private var selectedMode: TracingMode = .trace
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Drawing Mode")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Picker("Mode", selection: $selectedMode) {
                            Text("Trace").tag(TracingMode.trace)
                            Text("Scratch").tag(TracingMode.scratch)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Import Image")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            Button("From Gallery") {
                                showGalleryPicker = true
                            }
                            .buttonStylePrimary(color: .blue)
                            
                            Button("Take Photo") {
                                showCameraPicker = true
                            }
                            .buttonStylePrimary(color: .green)
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Browse Categories")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: {
                                categoryService.fetchCategories()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        if categoryService.isLoading {
                            ProgressView("Loading categories...")
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let errorMessage = categoryService.errorMessage {
                            VStack(spacing: 16) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.largeTitle)
                                    .foregroundColor(.orange)
                                
                                Text(errorMessage)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                
                                Button("Retry") {
                                    categoryService.fetchCategories()
                                }
                                .buttonStylePrimary(color: .blue)
                                .frame(width: 120)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else if categoryService.categories.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                
                                Text("No categories available")
                                    .foregroundColor(.secondary)
                                
                                Text("Categories will be available soon!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(categoryService.categories) { category in
                                    NavigationLink(destination: CategoryDetailView(
                                        categoryId: category.id,
                                        categoryName: category.name,
                                        tracingMode: selectedMode
                                    )) {
                                        CategoryCard(category: category)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom)
            }
            .onAppear {
                categoryService.fetchCategories()
            }
            .sheet(isPresented: $showGalleryPicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear { handleImageSelection() }
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker(selectedImage: $selectedImage)
                    .onDisappear { handleImageSelection() }
            }
            .background(
                NavigationLink(
                    destination: DetailView(
                        imageURL: nil,
                        selectedUIImage: selectedImage,
                        tracingMode: selectedMode
                    ),
                    isActive: $navigateToARView
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
    }
    
    private func handleImageSelection() {
        if selectedImage != nil {
            navigateToARView = true
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: CategoryPreview
    
    var body: some View {
        VStack(spacing: 12) {
            WebImage(url: URL(string: category.previewImage))
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.3))
                .scaledToFill()
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
            
            VStack(spacing: 4) {
                Text(category.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("\(category.imageCount) images")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(height: 50)
        }
        .frame(height: 210)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Button Style Extension
extension View {
    func buttonStylePrimary(color: Color) -> some View {
        self
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
