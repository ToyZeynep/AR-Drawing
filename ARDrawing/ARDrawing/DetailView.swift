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
    var tracingMode: TracingMode = .trace

    @GestureState private var dragOffset = CGSize.zero
    @GestureState private var rotationAngle: Angle = .zero
    @GestureState private var currentZoom: CGFloat = 1.0
    @State private var finalZoom: CGFloat = 1.0
    @State private var screenSize: CGSize = .zero
    @State private var previousBrightness: CGFloat = 0.0
    @State private var isLocked: Bool = false
    @State private var position = CGSize.zero
    @State private var finalAngle: Angle = .zero
    @State private var showHint = true
    @State private var image: UIImage? = nil
    @State private var imageOpacity: Double = 0.4
    @State private var showOpacitySettings = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Group {
                    if tracingMode == .trace {
                        CameraView()
                            .edgesIgnoringSafeArea(.all)
                    } else {
                        Color.white
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                
                VStack {
                    Spacer()
                        .frame(height: 50)
                    
                    if let selectedImage = selectedUIImage {
                        imageView(image: selectedImage)
                    } else if let image = image {
                        imageView(image: image)
                    } else {
                        Text("Failed to load image.")
                            .foregroundColor(tracingMode == .trace ? .white : .black)
                            .padding()
                            .background(tracingMode == .trace ? Color.black.opacity(0.5) : Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .padding()
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        if showHint {
                            Text(getHintText())
                                .padding()
                                .background(tracingMode == .trace ? Color.black.opacity(0.5) : Color.gray.opacity(0.2))
                                .foregroundColor(tracingMode == .trace ? .white : .black)
                                .cornerRadius(12)
                                .transition(.opacity)
                        }
                        
                        HStack(spacing: 16) {
                            Button(action: {
                                withAnimation(.spring()) {
                                    showOpacitySettings.toggle()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.system(size: 18))
                                    Text("Opacity")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(showOpacitySettings ? Color.blue.opacity(0.8) : Color.gray.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                            }
                            
                            Button(action: {
                                withAnimation(.spring()) {
                                    isLocked.toggle()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                                        .font(.system(size: 18))
                                    Text(isLocked ? "Screen Locked" : "Lock Screen")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(isLocked ? Color.green.opacity(0.8) : Color.gray.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                    .onAppear {
                        screenSize = geometry.size
                        
                        if tracingMode == .scratch {
                            centerImage()
                            setMaxBrightness()
                            imageOpacity = 1.0
                        }
                        
                        if let imageURL = imageURL {
                            loadImageFromURL(imageURL) { loadedImage in
                                DispatchQueue.main.async {
                                    self.image = loadedImage
                                    if self.tracingMode == .scratch {
                                        self.centerImage()
                                    }
                                }
                            }
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showHint = false
                            }
                        }
                    }
                    .onChange(of: tracingMode) { newMode in
                        if newMode == .scratch {
                            centerImage()
                            setMaxBrightness()
                            imageOpacity = 1.0
                        } else {
                            restoreBrightness()
                            imageOpacity = 0.4
                        }
                    }
                    .onDisappear {
                        restoreBrightness()
                    }
                }
                
                if showOpacitySettings {
                    ZStack {
                        Color.black.opacity(0.4)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    showOpacitySettings = false
                                }
                            }
                        
                        VStack(spacing: 12) {
                            Text("Opacity")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                            
                            VStack(spacing: 4) {
                                HStack {
                                    Text("0%")
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                    Spacer()
                                    Text("\(Int(imageOpacity * 100))%")
                                        .foregroundColor(.white)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("100%")
                                        .foregroundColor(.white)
                                        .font(.caption2)
                                }
                                
                                Slider(value: $imageOpacity, in: 0.0...1.0, step: 0.05)
                                    .accentColor(.blue)
                                    .frame(height: 16)
                            }
                            
                            Button("Done") {
                                withAnimation(.spring()) {
                                    showOpacitySettings = false
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                        }
                        .padding(16)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(16)
                        .padding(.horizontal, 50)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .offset(y: 240)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                }
            }
        }
        .navigationBarBackButtonHidden(isLocked)
        .navigationBarHidden(isLocked)
    }
    
    private func getHintText() -> String {
        if tracingMode == .trace {
            return "Move, rotate, zoom. Then start tracing on paper."
        } else {
            return "Place your phone on paper. Trace directly on screen."
        }
    }
    
    private func centerImage() {
        position = .zero
        finalZoom = 1.0
        finalAngle = .zero
    }

    private func setMaxBrightness() {
        previousBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }
    
    private func restoreBrightness() {
        if previousBrightness > 0 {
            UIScreen.main.brightness = previousBrightness
        }
    }

    @ViewBuilder
    func imageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .opacity(imageOpacity)
            .frame(width: 300, height: 300)
            .scaleEffect(finalZoom * currentZoom)
            .rotationEffect(finalAngle + rotationAngle)
            .offset(x: position.width + dragOffset.width,
                    y: position.height + dragOffset.height)
            .background(Color.clear)
            .gesture(
                isLocked ? nil :
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
