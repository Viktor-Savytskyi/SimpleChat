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


protocol ViewControllerPickerPresentable where Self: UIViewController {
    func presentOverParent(_ pickerView: UIViewController)
    func dismissFromParent()
}

extension ViewControllerPickerPresentable {
    func presentOverParent(_ pickerView: UIViewController) {
        present(pickerView, animated: true)
    }
    
    func dismissFromParent() {
        dismiss(animated: true)
    }
    
  
    
}

class LoginViewController: UIViewController, ViewControllerPickerPresentable {
    
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var enterButton: UIButton!
    
    lazy var loginViewModel = LoginViewModel(currentController: self)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addGestureRecognizers()
        loginViewModel.delegate = self
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
    
    @objc func editImage() {
        loginViewModel.showImagePickerAler { [weak self] image in
            guard let self else { return }
            DispatchQueue.main.async {
                self.avatarImageView.image = image
            }
        }
    }
    
    @IBAction func enterAction(_ sender: Any) {
//        GlobalRouter.shared.moveTo(screen: .chats)
        loginViewModel.createUser()

    }
    @IBAction func getUsersAction(_ sender: Any) {
        loginViewModel.getUsers()

    }
    
}

extension LoginViewController: LoginViewModelDelegate {
    
}
