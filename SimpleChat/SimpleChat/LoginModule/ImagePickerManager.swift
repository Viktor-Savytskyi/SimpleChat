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
    case galery
    case camera
    case cancel
    case fatalError
    case allow
    case necessaryMessage
    
    var description: String {
        switch self {
        case .choseImage:
            return "Chose image"
        case .selectOrPickImage:
            return "select or pick your image"
        case .galery:
            return "Galery"
        case .camera:
            return "Camera"
        case .cancel:
            return "Cancel"
        case .fatalError:
            return "Fatal error"
        case .allow:
            return "Allow"
        case .necessaryMessage:
            return "Camera access is absolutely necessary to use this app"
        }
    }
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
    
    func tryToOpenCamera(completion: (() -> Void)? = nil,
                         getpermissionAccessCompletion: ((UIAlertController) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
            guard let self else { return }
            DispatchQueue.main.async {
                if success {
                    completion?()
                } else {
                    self.presentCameraSettings(getpermissionAccessCompletion: getpermissionAccessCompletion)
                }
            }
        }
    }
    
    func presentCameraSettings(getpermissionAccessCompletion: ((UIAlertController) -> Void)? = nil) {
        let alert = UIAlertController(title: ImagePickerTitles.camera.description, message: ImagePickerTitles.necessaryMessage.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: ImagePickerTitles.cancel.description, style: .cancel))
        alert.addAction(UIAlertAction(title: ImagePickerTitles.allow.description, style: .default, handler: { action in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }))
        getpermissionAccessCompletion?(alert)
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
    
    func openPHPicker(completion: @escaping ((UIImage) -> Void)) -> PHPickerViewController {
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
