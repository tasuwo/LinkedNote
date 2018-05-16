//
//  BackupSection.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/05.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol BackupTargetSpecifiable {
    func getBackupTarget(at index: Int) -> BackupTargetType?
}

class BackupSection: NSObject, SettingViewSection, BackupTargetSpecifiable {
    static let BACKUP_BTN_SIGNATURE = "backup_signature"
    static let BACKUP_TARGET_BTN_SIGNATURE = "backup_target_signature"
    var delegate: SettingViewCellDelegate?
    var viewColors: ViewColorSettings?

    func getSectionTitle() -> String {
        return "バックアップ"
    }

    func numberOfColumns() -> Int {
        return BackupTargetType.count
    }

    func setDelegate(_ delegate: SettingViewCellDelegate) {
        self.delegate = delegate
    }

    func doDelegation(at _: Int) {
        return
    }

    func getCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BackupSection.BACKUP_TARGET_BTN_SIGNATURE, for: indexPath) as! BackupTargetCell

        cell.delegate = self.delegate
        cell.index = indexPath.row
        cell.titleLabel.text = BackupTargetType(rawValue: indexPath.row)?.toString() ?? ""

        if let target = getBackupTarget(at: indexPath.row) {
            if AppSettings.getIsBackup(target: target) == nil {
                AppSettings.setIsBackup(isBackup: false, target: target)
            }

            cell.isEnable.isOn = AppSettings.getIsBackup(target: target) ?? false
        } else {
            cell.isEnable.isOn = false
        }

        cell.selectionStyle = .none

        return cell
    }

    func setViewColorSetting(setting: ViewColorSettings) {
        self.viewColors = setting
    }

    func getBackupTarget(at index: Int) -> BackupTargetType? {
        return BackupTargetType(rawValue: index)
    }
}
