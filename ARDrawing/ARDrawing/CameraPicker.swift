//
//  CameraPicker.swift
//  ARDrawing
//
//  Created by Zeynep Toy on 11.05.2025.
//


import SwiftUI
import UIKit
import AVFoundation

struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedImage: UIImage?
    @State private var showingPermissionAlert = false

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker

        init(parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                 didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return createImagePicker(context: context)
            
        case .notDetermined:
            let placeholderVC = UIViewController()
            AVCaptureDevice.requestAccess(for: .video) { [weak placeholderVC] granted in
                DispatchQueue.main.async {
                    if granted {
                        let picker = self.createImagePicker(context: context)
                        placeholderVC?.present(picker, animated: true)
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            return placeholderVC
            
        case .denied, .restricted:
            let alertVC = createPermissionDeniedAlert()
            return alertVC
            
        @unknown default:
            let alertVC = createPermissionDeniedAlert()
            return alertVC
        }
    }
    
    private func createImagePicker(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    private func createPermissionDeniedAlert() -> UIViewController {
        let alertVC = UIViewController()
        
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Camera Permission Required",
                message: "We need camera access to take photos. Please enable camera permission in Settings.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
                self.presentationMode.wrappedValue.dismiss()
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                self.presentationMode.wrappedValue.dismiss()
            })
            
            alertVC.present(alert, animated: true)
        }
        
        return alertVC
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
