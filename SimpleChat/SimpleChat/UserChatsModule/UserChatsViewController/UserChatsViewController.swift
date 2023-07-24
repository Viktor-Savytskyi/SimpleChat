//
//  ChatsViewController.swift
//  SimpleChat
//
//  Created by Developer on 07.07.2023.
//

import UIKit

final class UserChatsViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var usersCollectionView: UICollectionView!
    @IBOutlet private weak var chatsTableView: UITableView!
    
    let userChatsViewModel = UserChatsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        prepareCollectionView() 
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func fetchUsers() {
        userChatsViewModel.fetchUsers {
            DispatchQueue.main.async {
                self.chatsTableView.reloadData()
                self.usersCollectionView.reloadData()
            }
        }
    }
    
    private func prepareTableView() {
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        chatsTableView.register(UserTableViewCell.nib, forCellReuseIdentifier: UserTableViewCell.identifier)
    }
    
    private func prepareCollectionView() {
        usersCollectionView.delegate = self
        usersCollectionView.dataSource = self
        usersCollectionView.register(UserCollectionViewCell.nib, forCellWithReuseIdentifier: UserCollectionViewCell.identifier)
    }
}

extension UserChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let id = userChatsViewModel.getUsers()[indexPath.row].id else { return }
        userChatsViewModel.moveToChat(with: id)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UserChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        userChatsViewModel.getUsers().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
        let user = userChatsViewModel.getUsers()[indexPath.row]
        cell.fillWith(user)
        return cell
    }
}

extension UserChatsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
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
