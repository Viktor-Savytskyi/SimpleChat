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
    var chatViewModel: ChatViewModel!
    var chatManager: ChatManager!
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatViewModel = ChatViewModel(chatManager: chatManager)
        configurateBottomMessageViewKeyboardAppereance()
        setupSearchBar()
        setupTableView()
        fetchUser(by: oponentID)
        showMessages()
        setupIsOponentTypingUI()
        messageTextField.delegate = self
    }
    
    func showMessages() {
        chatViewModel.getRoomMessages(userID: CurrentUser.shared.currentUser.id, oponentID: oponentID)
        scrollToBottom(isFirstLoading: isFirstLoading)
        chatViewModel.showNewMessages {
            self.chatViewModel.getRoomMessages(userID: CurrentUser.shared.currentUser.id, oponentID: self.oponentID)
            DispatchQueue.main.async {
                self.messagesTableView.reloadData()
                self.scrollToBottom(isFirstLoading: self.isFirstLoading)
            }
        }
    }
    
    func setupIsOponentTypingUI() {
        chatViewModel.isOponentTyping { isTyping in
            DispatchQueue.main.async {
                self.userView.showTypingAnimation(show: isTyping)
            }
        }
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
        userView.configure(user: user, onlineUsers: chatViewModel.getOnlineUsers(), state: .chatDetails)
        userView.dismissScreenDelegate = self
        self.user = user
        
        chatViewModel.setupUsersOnlineCompletion(onlineUserCompletion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.userView.configure(user: self.user, onlineUsers: self.chatViewModel.getOnlineUsers(), state: .chatDetails)
            }
        })
    }
    
    private func setupTableView() {
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(ChatTableViewCell.nib, forCellReuseIdentifier: ChatTableViewCell.identifier)
    }
    
    private func clearMessageField() {
        messageTextField.text = nil
    }
    
    func scrollToBottom(isFirstLoading: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        chatViewModel.sendTypingState(userID: CurrentUser.shared.currentUser.id, oponentID: oponentID, userTypingState: .typing)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        chatViewModel.sendTypingState(userID: CurrentUser.shared.currentUser.id, oponentID: oponentID, userTypingState: .stopTyping)
        return true
    }
    
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
