//
//  CategoryDetailView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 26.05.2025.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - Category Detail View

struct CategoryDetailView: View {
    let categoryId: String
    let categoryName: String
    let tracingMode: TracingMode
    
    @State private var category: Category?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @StateObject private var categoryService = CategoryService()
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading \(categoryName)...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(.orange)
                        
                        Text("Error Loading Images")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            fetchCategoryData()
                        }
                        .buttonStylePrimary(color: .blue)
                        .frame(maxWidth: 200)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 300)
                    
                } else if let category = category {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(category.images, id: \.self) { imageURL in
                            NavigationLink(destination: DetailView(
                                imageURL: imageURL,
                                tracingMode: tracingMode
                            )) {
                                ImageGridItem(imageURL: imageURL)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            fetchCategoryData()
        }
    }
    
    private func fetchCategoryData() {
        isLoading = true
        errorMessage = nil
        
        categoryService.fetchCategoryDetail(categoryId: categoryId) { [self] fetchedCategory in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let fetchedCategory = fetchedCategory {
                    self.category = fetchedCategory
                } else {
                    self.errorMessage = "Failed to load category images"
                }
            }
        }
    }
}

// MARK: - Image Grid Item

struct ImageGridItem: View {
    let imageURL: String
    @State private var isLoading = true
    @State private var loadFailed = false
    
    var body: some View {
        WebImage(url: URL(string: imageURL))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.3))
            .scaledToFill()
            .frame(height: 150)
            .clipped()
            .cornerRadius(8)
            .overlay(
                Group {
                    if loadFailed {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack(spacing: 4) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 20))
                                        .foregroundColor(.gray)
                                    Text("Failed")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
