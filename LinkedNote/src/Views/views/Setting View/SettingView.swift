//
//  SettingView.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/14.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import Foundation
import UIKit

protocol SettingViewDelegate {}

protocol SettingViewProvider {
    var view: UITableView { get }
}

class SettingView: UIView {
    var settingViewDelegate: SettingViewDelegate?
    let tableView: UITableView

    init() {
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        super.init(frame: CGRect.zero)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingView: SettingViewProvider {
    var view: UITableView {
        return self.tableView
    }
}
