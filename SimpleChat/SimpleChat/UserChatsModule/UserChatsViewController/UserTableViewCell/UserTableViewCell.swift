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

    func fillWith(_ room: UserRoom) {
        userView.configure(room, state: .chatList)
    }
}
