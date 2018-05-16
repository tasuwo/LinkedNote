//
//  SettingViewPresenter.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/14.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import RealmSwift
import UIKit

class SettingViewPresenter: NSObject {
    private(set) var sections: [SettingViewSection]
    private let backupTargetSpecifiable: BackupTargetSpecifiable

    override init() {
        let backupSection = BackupSection()
        self.backupTargetSpecifiable = backupSection
        self.sections = [
            AccountSection(),
            backupSection,
        ]
    }

    func setDelegate(_ delegate: SettingViewCellDelegate) {
        for section in self.sections {
            section.setDelegate(delegate)
        }
    }

    func setViewColorSetting(setting: ViewColorSettings) {
        for section in sections {
            section.setViewColorSetting(setting: setting)
        }
    }

    func getBackupTarget(by indexInSection: Int) -> BackupTargetType? {
        return self.backupTargetSpecifiable.getBackupTarget(at: indexInSection)
    }
}

protocol SettingViewSection {
    func getSectionTitle() -> String
    func numberOfColumns() -> Int
    func setDelegate(_: SettingViewCellDelegate)
    func doDelegation(at index: Int)
    func getCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func setViewColorSetting(setting: ViewColorSettings)
}

extension SettingViewPresenter: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return sections.count
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].getSectionTitle()
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections.count < section {
            return 0
        }

        return sections[section].numberOfColumns()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].getCell(tableView, cellForRowAt: indexPath)
    }
}
