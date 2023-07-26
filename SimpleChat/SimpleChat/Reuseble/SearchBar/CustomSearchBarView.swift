//
//  CustomSearchBar.swift
//  SimpleChat
//
//  Created by Developer on 25.07.2023.
//

import UIKit

enum SearchBarPlaceholders: String {
    case searchInChat = "Search in chat"
    case search = "Search..."
}

class CustomSearchBarView: UIView, LoadViewFromNib {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
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
    }
    
    func setupSearchBar(placeholder: String) {
        searchBar.placeholder = placeholder
    }
}
