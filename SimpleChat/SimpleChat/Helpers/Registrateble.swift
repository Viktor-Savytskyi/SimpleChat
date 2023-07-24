//
//  TableViewCellRegistrationProtocol.swift
//  SimpleChat
//
//  Created by Developer on 16.07.2023.
//

import UIKit

protocol Registrateble {
    static var identifier: String { get }
    static var nib: UINib { get }
}

extension Registrateble {
    static var identifier: String { String(describing: self) }
    static var nib: UINib { UINib(nibName: String(describing: self), bundle: nil)}
}
