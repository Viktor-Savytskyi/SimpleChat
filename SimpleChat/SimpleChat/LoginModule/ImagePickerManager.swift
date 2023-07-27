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
    case selectLimitedPhotos
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
        case .selectLimitedPhotos:
            return "Select limited photos"
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

enum AccessType {
    case authorized
    case limited
    case denied
}

enum SourceType: String {
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
    
    deinit {
       PHPhotoLibrary .shared().unregisterChangeObserver(self)
    }
    
    func showImagePickerAler(completion: @escaping (String) -> Void) {
        let imagePickerAlertView = UIAlertController(title: ImagePickerTitles.choseImage.description,
                                                     message: "",
                                                     preferredStyle: .actionSheet)
        
        let getFromCameraAction = UIAlertAction(title: ImagePickerTitles.camera.description, style: .default) { [weak self] _ in
            guard let self else { return }
            self.openCamera { imageURL in
                completion(imageURL)
            }
        }
        
        let pickFromGalleryAction = UIAlertAction(title: ImagePickerTitles.gallery.description, style: .default) { [weak self] _ in
            guard let self else { return }
            self.openGallery { imageURL in
                completion(imageURL)
            }
        }
        
        let cancelAction = UIAlertAction(title: ImagePickerTitles.cancel.description, style: .cancel)
        
        imagePickerAlertView.addAction(pickFromGalleryAction)
        imagePickerAlertView.addAction(getFromCameraAction)
        imagePickerAlertView.addAction(cancelAction)
        currentViewController.presentOverParent(imagePickerAlertView)
    }
    
    private func openCamera(completion: @escaping (String) -> Void) {
        var accessType: AccessType!
        AVCaptureDevice.requestAccess(for: .video) { [weak self] success in
            guard let self else { return }
            accessType = success ? .authorized : .denied
            
            DispatchQueue.main.async {
                if accessType == .authorized {
                    let cameraPicker = self.showCamera { [weak self] image in
                        guard let self else { return }
                        self.getUrlFromImage(image: image, completion: completion)
                    }
                    self.currentViewController.presentOverParent(cameraPicker)
                } else {
                    self.currentViewController.presentOverParent(self.showSettings(sourceType: .camera,
                                                                                   accessType: accessType))
                }
            }
        }
    }
    
    private func openGallery(completion: @escaping (String) -> Void) {
        var accessType: AccessType!
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            guard let self else { return }
            if status == .authorized {
                accessType = .authorized
            } else if status == .limited {
                accessType = .limited
            } else {
                accessType = .denied
            }
            
            DispatchQueue.main.async {
                switch accessType {
                case .authorized:
                    let phPicker = self.showPHPicker { [weak self] image in
                        guard let self else { return }
                        self.getUrlFromImage(image: image, completion: completion)
                    }
                    self.currentViewController.presentOverParent(phPicker)
                case .limited:
                    self.currentViewController.presentOverParent(self.showSettings(sourceType: .gallery,
                                                                                   accessType: accessType, completion: completion))
                case .denied:
                    self.currentViewController.presentOverParent(self.showSettings(sourceType: .gallery,
                                                                                   accessType: accessType))
                case .none:
                    print(ImagePickerTitles.fatalError.description)
                }
            }
            
        }
    }
    
    private func getUrlFromImage(image: UIImage, completion: ((String) -> Void)?) {
        let imageData = image.jpegData(compressionQuality: 1) ?? Data()
        FirebaseStorage.shared.saveImageWithUrl(image: imageData) { url, error in
            if (error != nil) {
                print(error?.localizedDescription ?? "")
            } else {
                completion?(url ?? "")
            }
        }
    }
    
    
    func showSettings(sourceType: SourceType, accessType: AccessType, completion: ((String) -> Void)? = nil) -> UIAlertController {
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
        
        if sourceType == .gallery && accessType == .limited  {
            let selectPhotosAction = UIAlertAction(title: ImagePickerTitles.selectLimitedPhotos.description,
                                                   style: .default) { [weak self] _ in
                guard let self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    PHPhotoLibrary.shared().register(self)
                    PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self.currentViewController)
                    //                    self.imageCompletion = completion
                }
            }
           
            let selectGaleryPhotosAction = UIAlertAction(title: "Pick limited photo from gallery",
                                                   style: .default)  { [weak self] _ in
                guard let self else { return }
                let phPicker = self.showPHPicker { [weak self] image in
                    guard let self else { return }
                    self.getUrlFromImage(image: image, completion: completion)
                }
                self.currentViewController.presentOverParent(phPicker)
            }
           
            
            alert.addAction(selectGaleryPhotosAction)
            alert.addAction(selectPhotosAction)
        }
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
        var phPickerConfig = PHPickerConfiguration()
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

extension ImagePickerManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        let fetchOptions = PHFetchOptions()
//        fetchOptions.fetchLimit = 1
        let images = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        
        print("limited images count = \(images.count)")
        let newImages = convertAssetsToImages(fetchResult: images)
        imageCompletion?(newImages.last ?? UIImage())
    }
}

extension ImagePickerManager {
    func convertAssetsToImages(fetchResult: PHFetchResult<PHAsset>) -> [UIImage] {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        var images: [UIImage] = []
        for index in 0..<fetchResult.count {
            let asset = fetchResult.object(at: index)
            manager.requestImage(for: asset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: options) { (image, _) in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
}

