//
//  ChatTableViewCell.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import UIKit

class ChatTableViewCell: UITableViewCell, Registrateble {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var messageDateLabel: UILabel!
    @IBOutlet weak var leftConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    let longConstraint = CGFloat(70)
    let shortConstraint = CGFloat(40)
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func fill(with messge: UserMessage, sendBy: SentBy) {
        messageLable.text = messge.message
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        messageDateLabel.text = dateFormatter.string(from: Date())
        backgroundColor = sendBy == .user ? .blue : .brown
        
        leftConstraint.constant = sendBy == .user ? longConstraint : shortConstraint
        rightConstraint.constant = sendBy == .user ? shortConstraint : longConstraint
        containerView.layoutIfNeeded()
    }
    
}
