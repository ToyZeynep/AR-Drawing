//
//  CameraView.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 10.05.2025.
//


import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @State private var isAuthorized = false
    @State private var showPermissionDenied = false
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        checkCameraPermission { authorized in
            DispatchQueue.main.async {
                if authorized {
                    self.isAuthorized = true
                    self.setupCamera(in: view)
                } else {
                    self.showPermissionDenied = true
                    self.setupPermissionDeniedView(in: view)
                }
            }
        }
        
        return view
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func setupCamera(in view: UIView) {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            setupErrorView(in: view, message: "Camera not found")
            return
        }
        
        session.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = UIScreen.main.bounds
        
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
    
    private func setupPermissionDeniedView(in view: UIView) {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView(image: UIImage(systemName: "camera.fill"))
        iconImageView.tintColor = UIColor.white
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = "Camera Permission Required"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        
        let messageLabel = UILabel()
        messageLabel.text = "We need camera access to use the AR drawing feature."
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        let settingsButton = UIButton(type: .system)
        settingsButton.setTitle("Go to Settings", for: .normal)
        settingsButton.setTitleColor(UIColor.white, for: .normal)
        settingsButton.backgroundColor = UIColor.systemBlue
        settingsButton.layer.cornerRadius = 8
        settingsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        settingsButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        
        settingsButton.addAction(UIAction { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        }, for: .touchUpInside)
        
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(messageLabel)
        stackView.addArrangedSubview(settingsButton)
        
        containerView.addSubview(stackView)
        view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -32),
            
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupErrorView(in view: UIView, message: String) {
        let label = UILabel()
        label.text = message
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if !isAuthorized && !showPermissionDenied {
            checkCameraPermission { authorized in
                DispatchQueue.main.async {
                    if authorized && !self.isAuthorized {
                        uiView.subviews.forEach { $0.removeFromSuperview() }
                        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
                        
                        self.isAuthorized = true
                        self.showPermissionDenied = false
                        self.setupCamera(in: uiView)
                    }
                }
            }
        }
    }
}
