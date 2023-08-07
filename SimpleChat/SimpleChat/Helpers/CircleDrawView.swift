//
//  RingView.swift
//  SimpleChat
//
//  Created by Developer on 27.07.2023.
//

import UIKit

@IBDesignable
class CircleDrawView: UIView {

    @IBInspectable var borderSize: CGFloat = 4
    @IBInspectable var borderColor: UIColor = UIColor.red {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    override func draw(_ rect: CGRect) {
//        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderSize
        layer.cornerRadius = frame.height / 2
    }
}
