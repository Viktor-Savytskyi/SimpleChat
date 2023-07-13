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
    case notNow
    case fatalError
    case allow
    case settings
    case selectLimitedPhotos
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
            return "Cancel"
        case .fatalError:
            return "Fatal error"
        case .allow:
            return "Allow"
        case .necessaryMessage(let type):
            return "Application should have access to your '\(type.rawValue.capitalized)'. It is absolutely necessary to use this app"
        case .notNow:
            return "Not now"
        case .selectLimitedPhotos:
            return "Select limited photos"
        case .settings:
            return "Settings"
        }
    }
}

enum SourceType: String {
    case camera
    case gallery
}

enum AccessType {
    case authorized
    case limited
    case denied
}

protocol ImagePickerDelegate {
    func show(vc: ViewControllerPickerPresentable)
    func dismiss(vc: ViewControllerPickerPresentable)
}

class ImagePickerManager: NSObject {
    
    var imageCompletion: ((UIImage) -> Void)?
    var pickerDelegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?
    var phPickerDelegate: PHPickerViewControllerDelegate?
    var currentViewController: ViewControllerPickerPresentable!
    
    required init(currentViewController: ViewControllerPickerPresentable) {
        super.init()
        pickerDelegate = self
        phPickerDelegate = self
        self.currentViewController = currentViewController
    }
    
    
    func showImagePickerAler(completion: @escaping (UIImage) -> Void) {
        let imagePickerAlertView = UIAlertController(title: ImagePickerTitles.choseImage.description,
                                                     message: ImagePickerTitles.selectOrPickImage.description,
                                                     preferredStyle: .actionSheet)
        
        let getFromCameraAction = UIAlertAction(title: ImagePickerTitles.camera.description, style: .default) { [weak self] _ in
            guard let self else { return }
            self.openCamera { image in
                completion(image)
            }
        }
        
        let pickFromGalleryAction = UIAlertAction(title: ImagePickerTitles.gallery.description, style: .default) { [weak self] _ in
            guard let self else { return }
            self.openGalery { image in
                completion(image)
            }
        }

        let cancelAction = UIAlertAction(title: ImagePickerTitles.cancel.description, style: .cancel)
        
        imagePickerAlertView.addAction(pickFromGalleryAction)
        imagePickerAlertView.addAction(getFromCameraAction)
        imagePickerAlertView.addAction(cancelAction)
        currentViewController.presentOverParent(imagePickerAlertView)
    }
    
    func openCamera(completion: @escaping (UIImage) -> Void) {
        var accessType: AccessType!
        AVCaptureDevice.requestAccess(for: .video) { success in
            accessType = success ? .authorized : .denied
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            if accessType == .authorized {
                let cameraPicker = self.showCamera { image in
                    completion(image)
                }
                self.currentViewController.presentOverParent(cameraPicker)
            } else {
                self.currentViewController.presentOverParent(self.showSettings(sourceType: .camera,
                                                                               accessType: accessType))
            }
        }
    }
    
    func openGalery(completion: @escaping (UIImage) -> Void) {
        var accessType: AccessType!
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized {
                accessType = .authorized
            } else if status == .limited {
                accessType = .limited
            } else {
                accessType = .denied
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch accessType {
            case .authorized:
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
    
    
    func showSettings(sourceType: SourceType, accessType: AccessType, completion: ((UIImage) -> Void)? = nil) -> UIAlertController {
        let title = sourceType == .camera ? ImagePickerTitles.camera.description : ImagePickerTitles.gallery.description
        
        let alert = UIAlertController(title: title,
                                      message: ImagePickerTitles.necessaryMessage(type: sourceType).description,
                                      preferredStyle: .alert)
        
        let moveToSettingsAction = (UIAlertAction(title: ImagePickerTitles.settings.description,
                                                  style: .default) { _ in
            self.gotoAppPrivacySettings()
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
                    self.imageCompletion = completion
                }
            }
            alert.addAction(selectPhotosAction)
        }
        return alert
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(url) else {
                    assertionFailure("Not able to open App privacy settings")
                    return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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

extension ImagePickerManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 1
        let images = PHAsset.fetchAssets(with: .image, options: fetchOptions)
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

