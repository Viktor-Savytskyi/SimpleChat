//
//  ImagePickerController.swift
//  SimpleChat
//
//  Created by Developer on 07.07.2023.
//

import UIKit
import Photos
import PhotosUI

class ImagePickerController: UIViewController {
    
}

//extension ViewController: PHPickerViewControllerDelegate {
//    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//         picker.dismiss(animated: true, completion: .none)
//         results.forEach { result in
//               result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
//               guard let image = reading as? UIImage, error == nil else { return }
//               DispatchQueue.main.async {
//                   self.profilePictureOutlet.image = image
//                   // TODO: - Here you get UIImage
//               }
//               result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] url, _ in
//                // TODO: - Here You Get The URL
//               }
//          }
//       }
//  }
//
//   /// call this method for `PHPicker`
//   func openPHPicker() {
//       var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
//       phPickerConfig.selectionLimit = 1
//       phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
//       let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
//       phPickerVC.delegate = self
//       present(phPickerVC, animated: true)
//   }
//}
