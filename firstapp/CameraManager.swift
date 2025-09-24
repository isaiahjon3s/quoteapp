//
//  CameraManager.swift
//  firstapp
//
//  Created by Isaiah Jones on 9/21/25.
//

import SwiftUI
import UIKit
import PhotosUI
import Combine

class CameraManager: NSObject, ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isShowingImagePicker = false
    @Published var isShowingActionSheet = false
    
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        self.sourceType = sourceType
        isShowingImagePicker = true
    }
    
    func showActionSheet() {
        isShowingActionSheet = true
    }
    
    func checkCameraPermission() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    func checkPhotoLibraryPermission() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension CameraManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }
        isShowingImagePicker = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShowingImagePicker = false
    }
}
