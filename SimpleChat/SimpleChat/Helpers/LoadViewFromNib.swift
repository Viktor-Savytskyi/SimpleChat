//
//  LoadViewFromNib.swift
//  SimpleChat
//
//  Created by Developer on 25.07.2023.
//

import UIKit

protocol LoadViewFromNib: Registrateble {
    func loadViewFromNib() -> UIView?
    func setup()
}

extension LoadViewFromNib {
    func loadViewFromNib() -> UIView? {
        Self.nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
}
