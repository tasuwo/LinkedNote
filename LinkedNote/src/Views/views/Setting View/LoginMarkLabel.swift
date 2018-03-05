//
//  LoginMarkLabel.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/06.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LoginMarkLabel: UILabel {
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = self.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = self.borderColor.cgColor
            self.textColor = self.borderColor
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth
        }
    }
}
