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

final class LoginViewController: UIViewController, ViewControllerPickerPresentable {
    
    @IBOutlet private weak var editImageView: UIImageView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameSkyTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var enterButton: UIButton!
    
    lazy private var loginViewModel = LoginViewModel(currentController: self)
    var avatarImageURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addGestureRecognizers()
        setupLoginViewModel()
    }
    
    private func prepareUI() {
        enterButton.layer.cornerRadius = enterButton.frame.height / 2
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        editImageView.layer.cornerRadius = editImageView.frame.height / 2
        firstNameSkyTextField.delegate = self
        lastNameSkyTextField.delegate = self
    }
    
    private func setupLoginViewModel() {
        loginViewModel.delegate = self
    }
    
    private func addGestureRecognizers() {
        let avatarImageGesture = UITapGestureRecognizer(target: self, action: #selector(editImage))
        let editImageGesture = UITapGestureRecognizer(target: self, action: #selector(editImage))
        editImageView.addGestureRecognizer(editImageGesture)
        avatarImageView.addGestureRecognizer(avatarImageGesture)
        editImageView.isUserInteractionEnabled = true
        avatarImageView.isUserInteractionEnabled = true
    }
    
    @objc private func editImage() {
        loginViewModel.showImagePickerAler { [weak self] imageURL in
            guard let self else { return }
            DispatchQueue.main.async {
                self.avatarImageView.sd_setImage(with: URL(string: imageURL), placeholderImage: UIImage(systemName: "person.circle.fill"))
                self.avatarImageURL = imageURL
            }
        }
    }
    
    @IBAction private func enterAction(_ sender: Any) {
        loginViewModel.loginWith(firstName: firstNameSkyTextField.text,
                                 lastName: lastNameSkyTextField.text,
                                 imageUrl: avatarImageURL)

    }
}

extension LoginViewController: LoginViewModelDelegate {
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameSkyTextField {
            lastNameSkyTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        return true
    }
}
