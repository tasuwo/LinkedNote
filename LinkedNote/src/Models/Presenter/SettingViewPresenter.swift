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

    override init() {
        self.sections = [
            AccountSection(),
            BackupSection(),
        ]
    }

    func setDelegate(_ delegate: SettingViewCellDelegate) {
        for section in self.sections {
            section.setDelegate(delegate)
        }
    }
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

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = SettingViewCell()

        let section = sections[indexPath.section]
        newCell.textLabel?.text = section.getColumnTitle(at: indexPath.row)
        newCell.selectionStyle = .none

        return newCell
    }
}

class SettingViewCell: UITableViewCell {
    var delegate: (() -> Void)?
}

protocol SettingViewCellDelegate {
    func didPressLogoutButton(type: String)
    func didPressAddApiButton()
    func didPressBackUpButton()
}

protocol SettingViewSection {
    func getSectionTitle() -> String
    func numberOfColumns() -> Int
    func getColumnTitle(at index: Int) -> String
    func setDelegate(_: SettingViewCellDelegate)
    func doDelegation(at index: Int)
}

class AccountSection: NSObject, SettingViewSection {
    var delegate: SettingViewCellDelegate?

    private let apiRepository: Repository<Api>
    private let apiAccountRepository: Repository<ApiAccount>
    private(set) var apis: Results<Api>
    private(set) var accounts: Results<ApiAccount>

    override init() {
        self.apiRepository = Repository<Api>()
        self.apiAccountRepository = Repository<ApiAccount>()
        self.apis = self.apiRepository.findAll()
        self.accounts = self.apiAccountRepository.findAll()
    }

    func getSectionTitle() -> String {
        return "アカウント"
    }

    func numberOfColumns() -> Int {
        return self.accounts.count + 1
    }

    func getColumnTitle(at index: Int) -> String {
        if index == self.accounts.count {
            return "追加"
        }

        // TODO: error handling
        return self.accounts[index].api.first?.signature ?? ""
    }

    func setDelegate(_ delegate: SettingViewCellDelegate) {
        self.delegate = delegate
    }

    func doDelegation(at index: Int) {
        if index == self.accounts.count {
            self.delegate?.didPressAddApiButton()
            return
        }

        guard let api = self.accounts[index].api.first else {
            // TODO: Error handling
            return
        }

        self.delegate?.didPressLogoutButton(type: api.signature)
    }
}

class BackupSection: NSObject, SettingViewSection {
    var delegate: SettingViewCellDelegate?

    func getSectionTitle() -> String {
        return "バックアップ"
    }

    func numberOfColumns() -> Int {
        return 1
    }

    func getColumnTitle(at _: Int) -> String {
        return "iCloud"
    }

    func setDelegate(_ delegate: SettingViewCellDelegate) {
        self.delegate = delegate
    }

    func doDelegation(at _: Int) {
        self.delegate?.didPressBackUpButton()
    }
}
