//
//  UserView.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import UIKit

enum CellType {
    case chatList
    case chatDetails
}

enum userOnlineState {
    case online
    case thirtyMinutesAsOffline
    case offline
}

class UserView: UIView, LoadViewFromNib {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var circleView: CircleDrawView!
    @IBOutlet weak var userFirstLastNameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    var dismissScreenDelegate: DismissScreenDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
    }
    
    func configure(user: User? = nil, room: RoomData? = nil, state: CellType) {
        messageTimeLabel.isHidden = true
        dismissButton.isHidden = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd-MM"
        var user = user 

        switch state {
        case .chatList:
            guard let room else { return }
            if let oponent = room.users.first(where: { $0.id != CurrentUser.shared.currentUser.id }) {
                user = oponent
            } else {
                user = CurrentUser.shared.currentUser
            }
            let lastMessage = room.messages.sorted(by: { $0.createdAt ?? Date() > $1.createdAt ?? Date()}).first
            messageLabel.text = lastMessage?.message ?? "Your message list already empty"
            if let messageDate = lastMessage?.createdAt {
                messageTimeLabel.text = dateFormatter.string(from: messageDate)
            } else {
                messageTimeLabel.text = ""
            }
        case .chatDetails:
            messageLabel.text = "Here will be isTyping status"
        }
        
//        checkOnlineState(date: user.lastOnlineDate)
        showElementsState(state: state)
        guard let user else { return }
        userFirstLastNameLabel.text = user.firstName + " " + user.lastName
        let placeholderImage = UIImage(systemName: Constants.Strings.avatarPlaceholder)?.withTintColor(.black)
        userImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: placeholderImage)

    }
    
    func checkOnlineState(date: Date?) {
        
    }
    
    func showElementsState(state: CellType) {
        switch state {
        case .chatList:
            messageTimeLabel.isHidden = false
            dismissButton.isHidden = true
        case .chatDetails:
            messageTimeLabel.isHidden = true
            dismissButton.isHidden = false
        }        
    }
    @IBAction func dismissAction(_ sender: Any) {
        dismissScreenDelegate?.dimsissFromView()
    }
}
