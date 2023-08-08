//
//  UserCollectionViewCell.swift
//  SimpleChat
//
//  Created by Developer on 17.07.2023.
//

import UIKit
import SDWebImage

class UserCollectionViewCell: UICollectionViewCell, Registrateble {

    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet private weak var firstNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
    }
    
    func fillAddNewUser() {
        avatarImageView.image = UIImage(named: "appAttachment")
        firstNameLabel.text = "Add New"
    }
    
    func fillWith(_ user: User) {
        let placeholderImage = UIImage(systemName: Constants.Strings.avatarPlaceholder)?.withTintColor(.black)
        avatarImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: placeholderImage) { _, _, _, _ in
            self.containerStackView.setNeedsLayout()
            self.avatarImageView.setNeedsLayout()
        }
        firstNameLabel.text = user.firstName
        self.containerStackView.setNeedsLayout()
        self.avatarImageView.setNeedsLayout()
    }
}
