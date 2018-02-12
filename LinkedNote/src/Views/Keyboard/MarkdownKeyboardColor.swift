//
//  MarkdownKeyboardColor.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/12.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

class MarkdownKeyboardColor {
    static func ofKeyboardBackground(at appearance: UIKeyboardAppearance) -> UIColor {
        switch appearance {
        case .dark:
            return UIColor(white: 0.00, alpha: 1)
        case .default, .light:
            return UIColor(hue: 0.67, saturation: 0, brightness: 0.87, alpha: 1)
        }
    }

    static func ofButton(at appearance: UIKeyboardAppearance) -> UIColor {
        switch appearance {
        case .dark:
            return UIColor(white: 0.90, alpha: 1)
        case .default, .light:
            return UIColor(white: 1, alpha: 1)
        }
    }

    static func ofButtonShadow(at appearance: UIKeyboardAppearance) -> UIColor {
        switch appearance {
        case .dark:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        case .default, .light:
            return UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        }
    }
}
