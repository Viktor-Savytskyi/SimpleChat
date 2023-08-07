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
    @IBOutlet weak var typingStatusStackView: UIStackView!
    @IBOutlet weak var dotsView: UIView!
    
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
    
    func configure(user: User? = nil, room: RoomData? = nil,
                   onlineUsers: [String : String?]?,
                   state: CellType) {
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
            let lastMessage = room.messages.last
            messageLabel.text = lastMessage?.message ?? "Your message list already empty"
            if let messageDate = lastMessage?.createdAt {
                messageTimeLabel.text = dateFormatter.string(from: messageDate)
            } else {
                messageTimeLabel.text = ""
            }
        case .chatDetails:
            messageLabel.text = ""
        }
        
        showElementsState(state: state)
        guard let user,
              let onlineUsers else { return }
        setCircleColor(user: user, onlineUsers: onlineUsers)
        userFirstLastNameLabel.text = user.firstName + " " + user.lastName
        let placeholderImage = UIImage(systemName: Constants.Strings.avatarPlaceholder)?.withTintColor(.black)
        userImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: placeholderImage)
    }
    
    func setCircleColor(user: User, onlineUsers: [String : String?]) {
        let onlineStatus = onlineUsers.first(where: { key, value in
            user.id == key
        })?.value
        circleView.borderColor = onlineStatus == nil
        ? .tintColor
        : .black
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
    
    func showTypingAnimation(show: Bool) {
        if show {
            messageLabel.text = "typing"
            createAnimatedDots()
        } else {
            messageLabel.text = nil
            removeAnimatedDots()
        }
    }
    
    func createAnimatedDots() {
        let lay = CAReplicatorLayer()
        lay.frame = CGRect(x: 0, y: -2, width: 6, height: 6)
        let bar = CALayer()
        bar.frame = CGRect(x: 0, y: -2, width: 2, height: 2)
        bar.cornerRadius = bar.frame.height / 2
        bar.backgroundColor = UIColor.black.cgColor
        lay.addSublayer(bar)
        lay.instanceCount = 3
        lay.instanceTransform = CATransform3DMakeTranslation(6, 0, 0)
        let anim = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        anim.fromValue = 1.0
        anim.toValue = 0.2
        anim.duration = 1
        anim.repeatCount = .infinity
        bar.add(anim, forKey: nil)
        lay.instanceDelay = anim.duration / Double(lay.instanceCount)
        dotsView.layer.addSublayer(lay)
    }
    
    func removeAnimatedDots() {
        dotsView.layer.sublayers?.removeAll()
    }
    
    @IBAction func dismissAction(_ sender: Any) {
        dismissScreenDelegate?.dimsissFromView()
    }
}
