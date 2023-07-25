//
//  CustomSearchBar.swift
//  SimpleChat
//
//  Created by Developer on 25.07.2023.
//

import UIKit

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
}
