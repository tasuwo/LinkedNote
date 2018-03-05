//
//  BackupSection.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/05.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

class BackupSection: NSObject, SettingViewSection {
    var delegate: SettingViewCellDelegate?
    var viewColors: ViewColorSettings?

    func getSectionTitle() -> String {
        return "バックアップ"
    }

    func numberOfColumns() -> Int {
        return 1
    }

    func setDelegate(_ delegate: SettingViewCellDelegate) {
        self.delegate = delegate
    }

    func doDelegation(at _: Int) {
        self.delegate?.didPressBackUpButton()
    }

    func getCell(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SettingViewCell()
        cell.textLabel?.text = self.getColumnTitle(at: indexPath.row)
        return cell
    }

    func setViewColorSetting(setting: ViewColorSettings) {
        self.viewColors = setting
    }

    private func getColumnTitle(at _: Int) -> String {
        return "iCloud"
    }
}
