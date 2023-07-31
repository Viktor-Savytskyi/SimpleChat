//
//  ViewController.swift
//  SimpleChat
//
//  Created by Developer on 17.07.2023.
//

import UIKit

protocol DismissScreenDelegate {
    func dimsissFromView()
}

enum SentBy: String {
    case user
    case opponent
}

class ChatViewController: UIViewController {
    @IBOutlet weak var userView: UserView!
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var customSearchBarView: CustomSearchBarView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var bottomMessageView: UIView!
    @IBOutlet weak var addAttachmentButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var bottomMessageViewConstraint: NSLayoutConstraint!
    
    var oponentID: String!
    var isFirstLoading = true
    let chatViewModel = ChatViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurateBottomMessageViewKeyboardAppereance()
        setupSearchBar()
        setupTableView()
        fetchUser(by: oponentID)
        messageTextField.delegate = self
        chatViewModel.setupWebSocket(userID: CurrentUser.shared.currentUser.id, oponentID: oponentID) {
            DispatchQueue.main.async {
                self.messagesTableView.reloadData()
                self.scrollToBottom(isFirstLoading: self.isFirstLoading)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        chatViewModel.closeWebSocket()
    }
    
    func setupSearchBar() {
        customSearchBarView.setupSearchBar(placeholder: SearchBarPlaceholders.searchInChat.rawValue)
    }
    
    private func fetchUser(by id: String) {
        chatViewModel.fetchUser(by: id) { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.setupUserData()
            }
        }
    }
    
    private func setupUserData() {
        let user = chatViewModel.getOponent()
        userView.configure(user: user, state: .chatDetails)
        userView.dismissScreenDelegate = self
    }
    
    private func setupTableView() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(ChatTableViewCell.nib, forCellReuseIdentifier: ChatTableViewCell.identifier)
    }
    
    private func clearMessageField() {
        messageTextField.text = ""
    }
    
    func scrollToBottom(isFirstLoading: Bool) {
        DispatchQueue.main.async {
             let indexPath = IndexPath(row: self.chatViewModel.getMessages().count-1, section: 0)
            guard indexPath.row > 0 else { return }
            self.messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: !isFirstLoading)
            self.isFirstLoading = false
        }
    }
    @IBAction func addAttachmentAction(_ sender: Any) {
        print("addAttachment")
        view.endEditing(true)
    }
    
    @IBAction func sendMessageAction(_ sender: Any) {
        guard let text = messageTextField.text else { return }
        chatViewModel.sendMessage(receiverID: oponentID, message: text)
        clearMessageField()
        view.endEditing(true)
    }
}

extension ChatViewController: DismissScreenDelegate {
    func dimsissFromView() {
        dismiss(animated: true)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chatViewModel.getMessages().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
            let message = chatViewModel.getMessages()[indexPath.row]
        let sendBy: SentBy = CurrentUser.shared.currentUser.id == message.senderID ? .user : .opponent
        cell.fill(with: message, sendBy: sendBy)
            return cell
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return true
    }
}

extension ChatViewController {
    private func configurateBottomMessageViewKeyboardAppereance() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomMessageViewConstraint.constant = keyboardFrame.size.height
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.bottomMessageViewConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
}
