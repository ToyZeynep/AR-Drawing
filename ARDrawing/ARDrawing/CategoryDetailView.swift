//
//  CategoryDetailView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 26.05.2025.
//

import SwiftUI
import SDWebImageSwiftUI
import FirebaseAnalytics

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
                        ForEach(Array(category.images.enumerated()), id: \.offset) { index, imageURL in
                            NavigationLink(destination: DetailView(
                                imageURL: imageURL,
                                tracingMode: tracingMode
                            )) {
                                ImageGridItem(imageURL: imageURL)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    Analytics.logEvent("image_selected", parameters: [
                                        "source": "category",
                                        "category_name": categoryName,
                                        "category_id": categoryId,
                                        "image_index": index,
                                        "mode": tracingMode == .trace ? "trace" : "scratch"
                                    ])
                                }
                            )
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
                    Analytics.logEvent("category_load_failed", parameters: [
                        "error_message": "Failed to load category images",
                        "category_id": categoryId,
                        "category_name": categoryName,
                        "location": "category_detail_view"
                    ])
                    self.errorMessage = "Failed to load category images"
                }
            }
        }
    }
}

// MARK: - Image Grid Item

struct ImageGridItem: View {
    let imageURL: String
    
    var body: some View {
        WebImage(url: URL(string: imageURL))
            .resizable()
            .indicator(.activity)
            .transition(.fade(duration: 0.3))
            .scaledToFill()
            .frame(height: 150)
            .clipped()
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
