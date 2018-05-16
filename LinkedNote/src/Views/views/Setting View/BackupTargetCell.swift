//
//  BackupTargetCell.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/09.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import Foundation
import UIKit

protocol BackupTargetCellDelegate {
    func didToggleBackupState(isOn: Bool, at: Int)
    func didPressRestoreButton(at: Int)
}

class BackupTargetCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var isEnable: UISwitch!
    @IBAction func didPressBackupStateToggleButton(_ sender: UISwitch) {
        if let i = index {
            self.delegate?.didToggleBackupState(isOn: sender.isOn, at: i)
        }
        // TODO: エラーハンドリング
    }

    @IBAction func didPressRestoreButton(_: Any) {
        if let i = index {
            self.delegate?.didPressRestoreButton(at: i)
        }
        // TODO: エラーハンドリング
    }

    var index: Int?
    var delegate: BackupTargetCellDelegate?
}
