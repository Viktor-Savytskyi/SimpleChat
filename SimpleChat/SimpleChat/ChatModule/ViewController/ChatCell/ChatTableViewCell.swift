//
//  ChatTableViewCell.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

enum ChatMessageSpaces: CGFloat {
    case ownerLeft = 80
    case ownerRight = 20
    case chatMateLeft = 40
    case chatMateRight = 70
}

import UIKit

class ChatTableViewCell: UITableViewCell, Registrateble {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func fill(with messge: UserMessage, sendBy: SentBy) {
        messageLable.text = messge.message
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        messageDateLabel.text = dateFormatter.string(from: Date())
        containerView.backgroundColor = sendBy == .user
            ? Constants.Colors.chatOwner
            : Constants.Colors.chatMate
        switch sendBy {
        case .user:
            leftConstraint.constant = ChatMessageSpaces.ownerLeft.rawValue
            rightConstraint.constant = ChatMessageSpaces.ownerRight.rawValue
        case .opponent:
            leftConstraint.constant = ChatMessageSpaces.chatMateLeft.rawValue
            rightConstraint.constant = ChatMessageSpaces.chatMateRight.rawValue
        }
        containerView.layoutIfNeeded()
    }
    
}
