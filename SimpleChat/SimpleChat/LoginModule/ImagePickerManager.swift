//
//  CameraManager.swift
//  SimpleChat
//
//  Created by Developer on 10.07.2023.
//

import UIKit
import Photos
import PhotosUI

private enum ImagePickerTitles {
    case choseImage
    case gallery
    case camera
    case cancel
    case notNow
    case allow
    case settings
    case necessaryMessage(type: SourceType)
    case moveToAppPrivacySettings
    case fatalError
    
    var description: String {
        switch self {
        case .choseImage:
            return "Chose image from"
        case .gallery:
            return "Gallery"
        case .camera:
            return "Camera"
        case .cancel:
            return "Cancel"
        case .allow:
            return "Allow"
        case .necessaryMessage(let type):
            return "Application need to have full access to your '\(type.rawValue.capitalized)'. It is absolutely necessary to use this app"
        case .notNow:
            return "Not now"
        case .settings:
            return "Settings"
        case .moveToAppPrivacySettings:
            return "Not able to open App privacy settings"
        case .fatalError:
            return "Fatal Error"
        }
    }
}

private enum SourceType: String {
    case camera
    case gallery
}


final class ImagePickerManager: NSObject {
    
    private var imageCompletion: ((UIImage) -> Void)?
    private var currentViewController: ViewControllerPickerPresentable!
    var pickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    var phPickerDelegate: PHPickerViewControllerDelegate?
    
    required init(currentViewController: ViewControllerPickerPresentable) {
        super.init()
        pickerDelegate = self
        phPickerDelegate = self
        self.currentViewController = currentViewController
    }
    
    func showImagePickerAler(completion: @escaping (UIImage) -> Void) {
        let imagePickerAlertView = UIAlertController(title: ImagePickerTitles.choseImage.description,
                                                     message: "",
                                                     preferredStyle: .actionSheet)
        
        let getFromCameraAction = UIAlertAction(title: ImagePickerTitles.camera.description, style: .default) { [weak self] _ in
            guard let self else { return }
            self.openCamera { image in
                completion(image)
            }
        }
        
        let pickFromGalleryAction = UIAlertAction(title: ImagePickerTitles.gallery.description, style: .default) { [weak self] _ in
            guard let self else { return }
            self.openGallery { image in
                completion(image)
            }
        }
        
        let cancelAction = UIAlertAction(title: ImagePickerTitles.cancel.description, style: .cancel)
        
        imagePickerAlertView.addAction(pickFromGalleryAction)
        imagePickerAlertView.addAction(getFromCameraAction)
        imagePickerAlertView.addAction(cancelAction)
        currentViewController.presentOverParent(imagePickerAlertView)
    }
    
    private func openCamera(completion: @escaping (UIImage) -> Void) {
        var isAuthorized: Bool = false
        AVCaptureDevice.requestAccess(for: .video) { success in
            isAuthorized = success
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if isAuthorized {
                let cameraPicker = self.showCamera { image in
                    completion(image)
                }
                self.currentViewController.presentOverParent(cameraPicker)
            } else {
                self.currentViewController.presentOverParent(self.showSettings(sourceType: .camera))
            }
        }
    }
    
    private func openGallery(completion: @escaping (UIImage) -> Void) {
        var isAuthorized: Bool = false
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            isAuthorized = status == .authorized
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if isAuthorized {
                let phPicker = self.showPHPicker { [weak self] image in
                    guard let self else { return }
                    completion(image)
                    let imageData = image.jpegData(compressionQuality: 1) ?? Data()
                    FirebaseStorage.shared.saveImageWithUrl(image: imageData) { [weak self] url, error in
                        //                        guard let self else { return }
                        if (error != nil) {
                            print(error?.localizedDescription ?? "")
                        } else {
                            print(url ?? "")
                        }
                    }
                }
                self.currentViewController.presentOverParent(phPicker)
            } else {
                self.currentViewController.presentOverParent(self.showSettings(sourceType: .gallery))
            }
        }
    }
    
    
    private func showSettings(sourceType: SourceType, completion: ((UIImage) -> Void)? = nil) -> UIAlertController {
        let title = sourceType == .camera ? ImagePickerTitles.camera.description : ImagePickerTitles.gallery.description
        
        let alert = UIAlertController(title: title,
                                      message: ImagePickerTitles.necessaryMessage(type: sourceType).description,
                                      preferredStyle: .alert)
        
        let moveToSettingsAction = (UIAlertAction(title: ImagePickerTitles.settings.description,
                                                  style: .default) { _ in
            self.moveToAppPrivacySettings()
        })
        
        let notNowAction = (UIAlertAction(title: ImagePickerTitles.notNow.description,
                                          style: .cancel))
        
        alert.addAction(moveToSettingsAction)
        alert.addAction(notNowAction)
        return alert
    }
    
    private func moveToAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure(ImagePickerTitles.moveToAppPrivacySettings.description)
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showCamera(completion: @escaping ((UIImage) -> Void)) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.modalPresentationStyle = .overCurrentContext
        picker.sourceType = .camera
        picker.delegate = pickerDelegate
        picker.allowsEditing = true
        imageCompletion = completion
        return picker
    }
    
    private func showPHPicker(completion: @escaping ((UIImage) -> Void)) -> PHPickerViewController {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
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
            print(ImagePickerTitles.fatalError.description)
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
