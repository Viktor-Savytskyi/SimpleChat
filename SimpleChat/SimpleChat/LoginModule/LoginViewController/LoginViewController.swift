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

protocol LoginViewControllerInput {
    
}

class LoginViewController: UIViewController {
    
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var enterButton: UIButton!
    
    var imagePickerManager: ImagePickerManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addGestureRecognizers()
        imagePickerManager = ImagePickerManager()

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
    
    func showImagePickerAler() {
        let imagePickerAlertView = UIAlertController(title: ImagePickerTitles.choseImage.description,
                                                     message: ImagePickerTitles.selectOrPickImage.description,
                                                     preferredStyle: .actionSheet)
        let pickFromGalleryAction = createPickFromAlertAction(sourceType: .gallery)
        let getFromCameraAction = createPickFromAlertAction(sourceType: .camera)
        let cancelAction = UIAlertAction(title: ImagePickerTitles.cancel.description, style: .cancel)
        
        imagePickerAlertView.addAction(pickFromGalleryAction)
        imagePickerAlertView.addAction(getFromCameraAction)
        imagePickerAlertView.addAction(cancelAction)
        self.present(imagePickerAlertView, animated: true)
    }
    
    func createPickFromAlertAction(sourceType: SourceType) -> UIAlertAction {
        var showCompletion: (() -> Void)?
        var title: String!
        
        switch sourceType {
        case .camera:
            title = ImagePickerTitles.camera.description
            showCompletion = {
                let cameraPicker = self.imagePickerManager.showCamera { [weak self] image in
                    guard let self else { return }
                    self.avatarImageView.image = image
                }
                self.present(cameraPicker, animated: true)
            }
        case .gallery:
            title = ImagePickerTitles.gallery.description
            showCompletion = {
                let phPicker = self.imagePickerManager.showPHPicker { [weak self] image in
                    guard let self else { return }
                    self.avatarImageView.image = image
                    let imageData = image.jpegData(compressionQuality: 1) ?? Data()
                    FirebaseStorage.createRef(image: imageData) { [weak self] url, error in
//                        guard let self else { return }
                        if (error != nil) {
                            print(error?.localizedDescription ?? "")
                        } else {
                            print(url ?? "")
                        }
                    }
                }
                self.present(phPicker, animated: true)
            }
        }
        
        return UIAlertAction(title: title, style: .default) { [weak self] _ in
            guard let self else { return }
            self.imagePickerManager.tryToOpen(type: sourceType,
                                              showCompletion: showCompletion,
                                              accessCompletion: { alert in self.present(alert, animated: true) })
        }
    }
    
    @objc func editImage() {
        showImagePickerAler()
    }
    
    @IBAction func enterAction(_ sender: Any) {
        GlobalRouter.shared.moveTo(screen: .chats)
    }
    
}

extension LoginViewController: LoginViewControllerInput {
    
}


