//
//  ChatsViewController.swift
//  SimpleChat
//
//  Created by Developer on 07.07.2023.
//

import UIKit

final class UserChatsViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet weak var currentUserImageView: UIImageView!
    @IBOutlet weak var currentUserFirstLastNameLabel: UILabel!
    @IBOutlet weak var customSearchBarView: CustomSearchBarView!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet private weak var chatsTableView: UITableView!
    
    let userChatsViewModel = UserChatsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCurrentUserData()
        setupSearchBar() 
        prepareTableView()
        prepareCollectionView() 
        userChatsViewModel.setupWebSocket(userID: CurrentUser.shared.currentUser.id) {
            DispatchQueue.main.async() {
                self.userChatsViewModel.createRoomsDataArray()
                self.chatsTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: false)
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        navigationController?.setNavigationBarHidden(false, animated: false)
//    }
    
    func setupSearchBar() {
        customSearchBarView.setupSearchBar(placeholder: SearchBarPlaceholders.search.rawValue)
    }
    
    private func fetchUsers() {
        userChatsViewModel.fetchUsers {
            DispatchQueue.main.async {
                self.usersCollectionView.reloadData()
                self.chatsTableView.reloadData()
            }
        }
    }
    
    private func fetchRooms() {
        userChatsViewModel.fetchRooms {
            DispatchQueue.main.async {
                self.chatsTableView.reloadData()
            }
        }
    }
    
    private func prepareTableView() {
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        chatsTableView.register(UserTableViewCell.nib,
                                forCellReuseIdentifier: UserTableViewCell.identifier)
    }
    
    private func prepareCollectionView() {
        usersCollectionView.delegate = self
        usersCollectionView.dataSource = self
        usersCollectionView.register(UserCollectionViewCell.nib,
                                     forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
    }
    
    private func setupCurrentUserData() {
        currentUserImageView.layer.cornerRadius = currentUserImageView.frame.height / 2
        currentUserImageView.sd_setImage(with: URL(string: CurrentUser.shared.currentUser.imageUrl), placeholderImage: UIImage(systemName: Constants.Strings.avatarPlaceholder))
        currentUserFirstLastNameLabel.text = CurrentUser.shared.currentUser.firstName + " " + CurrentUser.shared.currentUser.lastName
    }
}

extension UserChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let opponentID = userChatsViewModel.getRoomsData()[indexPath.row].users.first(where: { $0.id != CurrentUser.shared.currentUser.id
        })?.id
        let id = opponentID != nil ? opponentID! : CurrentUser.shared.currentUser.id
        userChatsViewModel.moveToChat(with: id, chatManager: userChatsViewModel.getChatManager())
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userChatsViewModel.getRoomsData().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
        let room = userChatsViewModel.getRoomsData()[indexPath.row]
        cell.fillWith(room)
        return cell
    }
}

extension UserChatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row > 0 {
            let id = userChatsViewModel.getUsers()[indexPath.row - 1].id
            userChatsViewModel.moveToChat(with: id, chatManager: userChatsViewModel.getChatManager())
        } else {
            print("New dialog tapped")
        }
    }
}

extension UserChatsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        userChatsViewModel.getUsers().count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.identifier, for: indexPath) as! UserCollectionViewCell
            cell.fillAddNewUser()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserCollectionViewCell.identifier, for: indexPath) as! UserCollectionViewCell
            let user = userChatsViewModel.getUsers()[indexPath.row - 1]
            cell.fillWith(user)
            return cell
        }
        
    }
    
    
}
