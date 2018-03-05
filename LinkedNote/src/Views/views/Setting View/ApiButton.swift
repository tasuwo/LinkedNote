//
//  ApiButton.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/06.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

@IBDesignable
class ApiButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.setTitleColor(self.borderColor, for: .normal)
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
}
