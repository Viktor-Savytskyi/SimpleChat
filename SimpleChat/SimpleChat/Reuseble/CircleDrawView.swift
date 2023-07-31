//
//  RingView.swift
//  SimpleChat
//
//  Created by Developer on 27.07.2023.
//

import UIKit

@IBDesignable
class CircleDrawView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.red;
    @IBInspectable var borderSize: CGFloat = 4

    override func draw(_ rect: CGRect) {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderSize
        layer.cornerRadius = self.frame.height/2
    }
}
