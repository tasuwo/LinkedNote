//
//  AccountSection.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/05.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import RealmSwift
import UIKit

class AccountSection: NSObject, SettingViewSection {
    var delegate: SettingViewCellDelegate?
    var viewColors: ViewColorSettings?

    static let ACCOUNT_BTN_SIGNATURE = "account_btn"

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

        self.delegate?.didPressAccountButton(
            signature: api.signature,
            userName: self.accounts[index].username,
            isLoggedIn: self.loggedIn(at: index)
        )
    }

    func getCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == self.accounts.count {
            let newCell = SettingViewCell()
            newCell.textLabel!.text = "追加"
            newCell.textLabel!.textColor = self.viewColors?.getTintColor() ?? UIColor.blue
            return newCell
        }

        let newCell = tableView.dequeueReusableCell(withIdentifier: AccountSection.ACCOUNT_BTN_SIGNATURE, for: indexPath) as! SettingAccountCustomCell
        newCell.apiNameLabel.text = self.getColumnTitle(at: indexPath.row)
        newCell.usernameLabel.text = self.getUsername(at: indexPath.row)
        if self.loggedIn(at: indexPath.row) {
            newCell.loginMark.isHidden = false
        } else {
            newCell.loginMark.isHidden = true
        }
        newCell.apiImageView.image = UIImage.colorImage(
            color: UIColor(r: 220, g: 220, b: 220),
            // TODO: Research for the situation that the thumbnail is nil
            size: newCell.apiImageView?.frame.size ?? CGSize.zero
        )

        return newCell
    }

    func setViewColorSetting(setting: ViewColorSettings) {
        self.viewColors = setting
    }

    private func getColumnTitle(at index: Int) -> String {
        if index == self.accounts.count {
            return "追加"
        }

        guard let signature = self.accounts[index].api.first?.signature else {
            // TODO: Error handling
            return ""
        }

        return signature
    }

    private func getUsername(at index: Int) -> String {
        if index >= self.accounts.count {
            // TODO: Error handling
            return ""
        }
        return self.accounts[index].username
    }

    private func loggedIn(at index: Int) -> Bool {
        if index >= self.accounts.count {
            return false
        }

        guard let api = self.accounts[index].api.first else {
            return false
        }

        let username = self.accounts[index].username

        switch api.signature {
        case PocketAPIWrapper.signature:
            return PocketAPIWrapper.isLoggedIn() && PocketAPIWrapper.getUsername() == username
        default:
            return false
        }
    }
}
