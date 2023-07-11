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
    
    var imagePickerManager: ImagePickerManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addGestureRecognizers()
        setupCameraManager()
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
    
    private func setupCameraManager() {
        imagePickerManager = ImagePickerManager()
    }
    
    func addGestureRecognizers() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(editImage))
        editImageView.addGestureRecognizer(gesture)
        editImageView.isUserInteractionEnabled = true
    }
    
    func showImagePickerAlerView() {
        let imagePickerAlertView = UIAlertController(title: ImagePickerTitles.choseImage.description,
                                                     message: ImagePickerTitles.selectOrPickImage.description,
                                                     preferredStyle: .actionSheet)
        let pickFromGaleryAction = UIAlertAction(title: ImagePickerTitles.galery.description, style: .default) { [weak self] _ in
            guard let self else { return }
            let pHPicker = self.imagePickerManager.openPHPicker { [weak self] image in
                guard let self else { return }
                self.avatarImageView.image = image
            }
            self.present(pHPicker, animated: true)
        }
        
        let getFromCameraAction = UIAlertAction(title: ImagePickerTitles.camera.description, style: .default) { [weak self] _ in
            guard let self else { return }
            self.imagePickerManager.tryToOpenCamera(
                completion: {
                    let picker = self.imagePickerManager.showCamera { image in
                        self.avatarImageView.image = image
                    }
                    self.present(picker, animated: true)
                }, getpermissionAccessCompletion: { alert in
                    self.present(alert, animated: true)
                })
        }
        
        let cancelAction = UIAlertAction(title: ImagePickerTitles.cancel.description, style: .cancel)
        
        imagePickerAlertView.addAction(pickFromGaleryAction)
        imagePickerAlertView.addAction(getFromCameraAction)
        imagePickerAlertView.addAction(cancelAction)
        self.present(imagePickerAlertView, animated: true)
    }
    
    @objc func editImage() {
        showImagePickerAlerView()
    }
    
    @IBAction func enterAction(_ sender: Any) {
        GlobalRouter.shared.moveTo(screen: .chats)
    }
    
}


