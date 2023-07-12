//
//  CameraManager.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit
import Photos
import PhotosUI

enum ImagePickerTitles {
    case choseImage
    case selectOrPickImage
    case gallery
    case camera
    case cancel
    case fatalError
    case allow
    case necessaryMessage(type: SourceType)
    
    var description: String {
        switch self {
        case .choseImage:
            return "Chose image"
        case .selectOrPickImage:
            return "select or pick your image"
        case .gallery:
            return "Gallery"
        case .camera:
            return "Camera"
        case .cancel:
            return "Not now"
        case .fatalError:
            return "Fatal error"
        case .allow:
            return "Allow"
        case .necessaryMessage(let type):
            return "Application should have full access to your '\(type.rawValue.uppercased())'. It is absolutely necessary to use this app"
        }
    }
}

enum SourceType: String {
    case camera
    case gallery
}

class ImagePickerManager: NSObject {
    
    var imageCompletion: ((UIImage) -> Void)?
    var pickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    var phPickerDelegate: PHPickerViewControllerDelegate?
    
    override init() {
        super.init()
        pickerDelegate = self
        phPickerDelegate = self
    }
    
    func tryToOpen(type: SourceType,
                   showCompletion: (() -> Void)? = nil,
                   accessCompletion: ((UIAlertController) -> Void)? = nil) {
        var isAuthorized = false
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { success in
                isAuthorized = success
            }
        case .gallery:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                isAuthorized = status == .authorized
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if isAuthorized {
                showCompletion?()
            } else {
                self.showSettings(sourceType: type, accessCompletion: accessCompletion)
            }
        }
        
    }
    
    func showSettings(sourceType: SourceType, accessCompletion: ((UIAlertController) -> Void)? = nil) {
        let title = sourceType == .camera ? ImagePickerTitles.camera.description : ImagePickerTitles.gallery.description
        let alert = UIAlertController(title: title, message: ImagePickerTitles.necessaryMessage(type: sourceType).description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ImagePickerTitles.cancel.description, style: .cancel))
        alert.addAction(UIAlertAction(title: ImagePickerTitles.allow.description, style: .default, handler: { action in
            self.gotoAppPrivacySettings()
        }))
        accessCompletion?(alert)
    }
    
    func gotoAppPrivacySettings() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
    }
    
    func showCamera(completion: @escaping ((UIImage) -> Void)) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.modalPresentationStyle = .overCurrentContext
        picker.sourceType = .camera
        picker.delegate = pickerDelegate
        picker.allowsEditing = true
        imageCompletion = completion
        return picker
    }
    
    func showPHPicker(completion: @escaping ((UIImage) -> Void)) -> PHPickerViewController {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .images])
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.modalPresentationStyle = .overCurrentContext
        phPickerVC.delegate = phPickerDelegate
        imageCompletion = completion
        return phPickerVC
    }
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.imageCompletion?(image)
        } else {
            print("fatal error")
        }
        picker.dismiss(animated: true)
    }
}

extension ImagePickerManager: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.imageCompletion?(image)
                }
            }
        }
    }
}
