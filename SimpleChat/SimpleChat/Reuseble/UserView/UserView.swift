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
    
    func configure(_ room: UserRoom,
                   state: CellType) {
        messageTimeLabel.isHidden = true
        dismissButton.isHidden = true
        let placeholderImage = UIImage(systemName: "person.circle.fill")?.withTintColor(.black)
//        userImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: placeholderImage)
//        userFirstLastNameLabel.text = user.firstName + " " + user.lastName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd-MM"
//        messageTimeLabel.text = dateFormatter.string(from: user.lastOnlineDate ?? Date())
        showElementsState(state: state)
//        checkOnlineState(date: user.lastOnlineDate)
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
        
        messageLabel.text =  state == .chatDetails ? "is online?" : "message for chat table"
    }
    @IBAction func dismissAction(_ sender: Any) {
        dismissScreenDelegate?.dimsissFromView()
    }
}
