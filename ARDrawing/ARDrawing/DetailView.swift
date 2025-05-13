//
//  DetailView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 10.05.2025.
//


import SwiftUI
import PhotosUI

struct DetailView: View {
    var imageURL: String? = nil
    var selectedUIImage: UIImage? = nil

    @GestureState private var dragOffset = CGSize.zero
    @State private var position = CGSize.zero

    @GestureState private var currentZoom: CGFloat = 1.0
    @State private var finalZoom: CGFloat = 1.0

    @GestureState private var rotationAngle: Angle = .zero
    @State private var finalAngle: Angle = .zero

    @State private var image: UIImage? = nil
    
    @State private var showHint = true


    var body: some View {
        ZStack {
            CameraView()
                .edgesIgnoringSafeArea(.all)

            VStack {
                if let selectedImage = selectedUIImage {
                    imageView(image: selectedImage)
                } else if let image = image {
                    imageView(image: image)
                } else {
                    Text("Failed to load image.")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding()
                }

                Spacer()

                if showHint {
                    Text("Move, rotate, zoom. Then start tracing on paper.")
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding()
                        .transition(.opacity)
                }
            }
        }
        .onAppear {
            if let imageURL = imageURL {
                loadImageFromURL(imageURL) { loadedImage in
                    DispatchQueue.main.async {
                        self.image = loadedImage
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                withAnimation {
                    showHint = false
                }
            }
        }
    }

    @ViewBuilder
    func imageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .opacity(0.4)
            .frame(width: 300, height: 300)
            .scaleEffect(finalZoom * currentZoom)
            .rotationEffect(finalAngle + rotationAngle)
            .offset(x: position.width + dragOffset.width,
                    y: position.height + dragOffset.height)
            .gesture(
                SimultaneousGesture(
                    SimultaneousGesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                let newX = position.width + value.translation.width
                                let newY = position.height + value.translation.height
                                position.width = max(min(newX, 150), -150)
                                position.height = max(min(newY, 450), -150)
                            },
                        MagnificationGesture()
                            .updating($currentZoom) { value, state, _ in
                                state = value
                            }
                            .onEnded { value in
                                let newZoom = finalZoom * value
                                finalZoom = min(max(newZoom, 0.5), 2.5)
                            }
                    ),
                    RotationGesture()
                        .updating($rotationAngle) { value, state, _ in
                            state = value
                        }
                        .onEnded { value in
                            finalAngle += value
                        }
                )
            )
    }

    func loadImageFromURL(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
}
