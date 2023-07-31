//
//  ChatTableViewCell.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import UIKit

private enum ChatMessageConstraints: CGFloat {
    case ownerLeft = 80
    case ownerRight = 20
    case oponentLeft = 40
    case oponentRight = 70
}

final class ChatTableViewCell: UITableViewCell, Registrateble {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    func fill(with message: UserMessage, sendBy: SentBy) {
        guard let dateString = message.createdAt else { return }
        messageLable.text = message.message
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd-MM"
        messageDateLabel.text = dateFormatter.string(from: dateString)
        containerView.backgroundColor = sendBy == .user
            ? Constants.Colors.chatOwner
            : Constants.Colors.chatMate
        switch sendBy {
        case .user:
            leftConstraint.constant = ChatMessageConstraints.ownerLeft.rawValue
            rightConstraint.constant = ChatMessageConstraints.ownerRight.rawValue
        case .opponent:
            leftConstraint.constant = ChatMessageConstraints.oponentLeft.rawValue
            rightConstraint.constant = ChatMessageConstraints.oponentRight.rawValue
        }
        containerView.layoutIfNeeded()
    }
}
