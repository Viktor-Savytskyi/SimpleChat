//
//  ViewController.swift
//  SimpleChat
//
//  Created by Developer on 07.07.2023.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage
import Photos
import PhotosUI

class LoginViewController: UIViewController {
    
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addGestureRecognizers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func prepareUI() {
        enterButton.layer.cornerRadius = enterButton.frame.height / 2
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        editImageView.layer.cornerRadius = editImageView.frame.height / 2
    }
    
    func addGestureRecognizers() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(editImage))
        editImageView.addGestureRecognizer(gesture)
        editImageView.isUserInteractionEnabled = true
    }
    
    func showImagePickerAlerView() {
        let imagePickerAlertView = UIAlertController(title: "Chose image", message: "select or pick image", preferredStyle: .actionSheet)
        let pickFromGaleryAction = UIAlertAction(title: "Galery", style: .default) { [weak self] _ in
            guard let self else { return }
            self.present(self.openCameraPicker(sourseType: .photoLibrary), animated: true)
        }
        
        let getFromCameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            guard let self else { return }
            self.present(self.openCameraPicker(sourseType: .camera), animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        imagePickerAlertView.addAction(pickFromGaleryAction)
        imagePickerAlertView.addAction(getFromCameraAction)
        imagePickerAlertView.addAction(cancelAction)
        self.present(imagePickerAlertView, animated: true)
    }
    
    @objc func editImage() {
        showImagePickerAlerView()
    }


    @IBAction func enterAction(_ sender: Any) {
        print("enter")
        let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatsViewController") as! ChatsViewController
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func getAllowToUseCamera() {
        //Camera
           AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
               if response {
                   //access granted
               } else {
                   // Create Alert
                     let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)

                     // Add "OK" Button to alert, pressing it will bring you to the settings app
                     alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                         UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                     }))
                     // Show the alert with animation
                     self.present(alert, animated: true)
               }
           }

           //Photos
           let photos = PHPhotoLibrary.authorizationStatus()
           if photos == .notDetermined {
               PHPhotoLibrary.requestAuthorization({status in
                   if status == .authorized{
                      //
                   } else {
                       
                   }
               })
           }
    }
    
    func openCameraPicker(sourseType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourseType
        picker.delegate = self
        return picker
        
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.avatarImageView.image = image
        self.dismiss(animated: true)
    }
}

// MARK: - PHPicker Configurations (PHPickerViewControllerDelegate)
extension LoginViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
         picker.dismiss(animated: true, completion: .none)
         results.forEach { result in
               result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
               guard let image = reading as? UIImage, error == nil else { return }
               DispatchQueue.main.async {
                   self.avatarImageView.image = image
                   // TODO: - Here you get UIImage
               }
//               result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { [weak self] url, _ in
//                // TODO: - Here You Get The URL
//               }
          }
       }
  }

   /// call this method for `PHPicker`
   func openPHPicker() {
       var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
       phPickerConfig.selectionLimit = 1
       phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
       let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
       phPickerVC.delegate = self
       present(phPickerVC, animated: true)
   }
}
