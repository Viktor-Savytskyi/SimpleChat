//
//  TableViewCell.swift
//  SimpleChat
//
//  Created by Developer on 16.07.2023.
//

import UIKit
import SDWebImage

final class UserTableViewCell: UITableViewCell, RegistratedTableCell {

    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var userFirstLastNameLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var messageTimeLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userFirstLastNameLabel.text = "test text"
        messageLabel.text = "test text"
        messageTimeLabel.text = "test text"
    }

    func fillWith(_ user: User) {
        userImageView.sd_setImage(with: URL(string: user.imageUrl))
        userFirstLastNameLabel.text = user.firstName + " " + user.lastName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        messageTimeLabel.text = dateFormatter.string(from: Date())
    }
    
}
