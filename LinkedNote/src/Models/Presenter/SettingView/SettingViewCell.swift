//
//  SettingViewCell.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/05.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

class SettingViewCell: UITableViewCell {
    var delegate: (() -> Void)?
}

protocol SettingViewCellDelegate {
    func didPressAccountButton(signature: String, userName: String, isLoggedIn: Bool)
    func didPressAddApiButton()
    func didPressBackUpButton()
}
