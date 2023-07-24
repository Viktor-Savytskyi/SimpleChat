//
//  TableViewCell.swift
//  SimpleChat
//
//  Created by Developer on 16.07.2023.
//

import UIKit
import SDWebImage

final class UserTableViewCell: UITableViewCell, Registrateble {
    
    @IBOutlet weak var userView: UserView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        userView.userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }

    func fillWith(_ user: User) {
        userView.configure(user, state: .date) {
            print("asdnasdasjdja")
        }

//        userImageView.sd_setImage(with: URL(string: user.imageUrl))
//        userFirstLastNameLabel.text = user.firstName + " " + user.lastName
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "HH:mm dd-MM"
//        messageTimeLabel.text = dateFormatter.string(from: Date())
    }
}
