//
//  UserView.swift
//  SimpleChat
//
//  Created by Developer on 18.07.2023.
//

import UIKit

enum ViewState {
    case date
    case dismiss
}

class UserView: UIView, Registrateble {
    @IBOutlet weak var userImageView: UIImageView!
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
    
    func configure(_ user: User, state: ViewState, completion: ((() -> Void)?) = nil) {
        messageTimeLabel.isHidden = true
        dismissButton.isHidden = true
        userImageView.sd_setImage(with: URL(string: user.imageUrl), placeholderImage: UIImage(systemName: "person.circle.fill"))
        userFirstLastNameLabel.text = user.firstName + " " + user.lastName
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm dd-MM"
        messageTimeLabel.text = dateFormatter.string(from: Date())
        showElementsState(state: state)
    }
    
    func loadViewFromNib() -> UIView? {
        Self.nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func showElementsState(state: ViewState) {
        switch state {
        case .date:
            messageTimeLabel.isHidden = false
            dismissButton.isHidden = true
        case .dismiss:
            messageTimeLabel.isHidden = true
            dismissButton.isHidden = false
        }
        
        messageLabel.text =  state == .dismiss ? "is online?" : "message for chat table"
    }
    @IBAction func dismissAction(_ sender: Any) {
        dismissScreenDelegate?.dimsissFromView()
    }
}
