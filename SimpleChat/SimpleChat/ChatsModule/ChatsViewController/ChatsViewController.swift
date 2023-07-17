//
//  ChatsViewController.swift
//  SimpleChat
//
//  Created by Developer on 07.07.2023.
//

import UIKit

final class ChatsViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var chatsTableView: UITableView!
    
    let chatsViewModel = ChatsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTableView()
        chatsViewModel.fetchUsers {
            DispatchQueue.main.async {
                self.chatsTableView.reloadData()
            }
        }
    }
    
    private func prepareTableView() {
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        chatsTableView.register(UserTableViewCell.nib, forCellReuseIdentifier: UserTableViewCell.identifier)
    }
}

extension ChatsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatsViewModel.getUsers().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as! UserTableViewCell
        cell.fillWith(chatsViewModel.getUsers()[indexPath.row])
        return cell
    }
}


extension ChatsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
