//
//  SettingViewController.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/14.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {
    let provider: SettingViewProvider
    let presenter: SettingViewPresenter
    let calculator: FrameCalculator
    let tagListPresenter: TagListPresenter
    let alertPresenter: AlertPresenter

    let tagRepository: Repository<Tag>

    init(provider: SettingViewProvider, presenter: SettingViewPresenter, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.provider = provider
        self.presenter = presenter
        self.calculator = calculator
        self.tagListPresenter = TagListPresenter()
        self.alertPresenter = alertPresenter
        // TODO: Factory pattern
        self.tagRepository = Repository<Tag>()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter.setDelegate(self)
        self.presenter.setViewColorSetting(setting: self.provider.view)

        self.provider.view.frame = self.calculator.calcFrameOnTabAndNavBar(by: self)
        self.provider.view.delegate = self
        self.provider.view.dataSource = self.presenter
        self.view.addSubview(self.provider.view)

        self.navigationItem.title = "設定"
    }

    override func viewWillAppear(_: Bool) {
        self.provider.view.reloadData()
    }

    override func viewDidAppear(_: Bool) {
        if let indexPath = self.provider.view.indexPathForSelectedRow {
            self.provider.view.deselectRow(at: indexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SettingViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.presenter.sections[indexPath.section]
        section.doDelegation(at: indexPath.row)
    }
}

extension SettingViewController: SettingViewCellDelegate {
    func didPressAddApiButton() {
        let vc = SignInViewController(provider: SignInView(), calculator: self.calculator, alertPresenter: self.alertPresenter)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func didPressAccountButton(signature: String, userName: String, isLoggedIn: Bool) {
        if isLoggedIn {
            self.logoutFrom(signature, userName)
        } else {
            self.loginTo(signature, userName)
        }
    }

    private func loginTo(_ signature: String, _ username: String) {
        alertPresenter.yn(
            title: "ログイン",
            message: "\(signature) に \(username) としてログインしますか？",
            on: self,
            y: { _ in
                PocketAPIWrapper.logout()
                PocketAPIWrapper.login(completion: { error in
                    if let e = error {
                        self.alertPresenter.error(e.localizedDescription, on: self)
                        return
                    }
                    self.provider.view.reloadData()
                })
            },
            n: { _ in }
        )
    }

    private func logoutFrom(_ signature: String, _: String) {
        alertPresenter.yn(
            title: "ログアウト",
            message: "\(signature) からログアウトしますか？",
            on: self,
            y: { _ in
                PocketAPIWrapper.logout()
                self.provider.view.reloadData()
            },
            n: { _ in }
        )
    }

    func didToggleBackupState(isOn: Bool, at index: Int) {
        guard let target = self.presenter.getBackupTarget(by: index) else {
            // TODO: error handling
            return
        }

        guard let strategy = target.getStrategy() else {
            self.alertPresenter.check(
                "バックアップを有効化できません",
                "未実装です",
                on: self,
                { _ in self.provider.view.reloadData() }
            )
            return
        }

        if !strategy.isAvailable() {
            self.alertPresenter.check(
                "バックアップを有効化できません",
                "ここに何が問題だったか書く",
                on: self,
                { _ in self.provider.view.reloadData() }
            )
            return
        }

        let title: String
        let message: String
        let isBackupAtY: Bool
        let isBackupAtN: Bool
        if isOn {
            title = "バックアップの有効化"
            message = "バックアップが自動的に作成されます。\n他の端末でのバックアップデータが存在する場合、上書きされます。"
            isBackupAtY = true
            isBackupAtN = false
        } else {
            title = "バックアップの無効化"
            message = "アプリ内のデータは削除されません。\nまた、バックアップ済みのデータも削除されずに残ります。"
            isBackupAtY = false
            isBackupAtN = true
        }

        alertPresenter.yn(
            title: title,
            message: message,
            on: self,
            y: { _ in
                AppSettings.setIsBackup(isBackup: isBackupAtY, target: target)
                self.provider.view.reloadData()
            },
            n: { _ in
                AppSettings.setIsBackup(isBackup: isBackupAtN, target: target)
                self.provider.view.reloadData()
            }
        )
    }

    func didPressRestoreButton(at index: Int) {
        guard let target = self.presenter.getBackupTarget(by: index),
            let strategy = target.getStrategy(),
            let isBackupEnabled = AppSettings.getIsBackup(target: target) else {
            // TODO: エラーハンドリング
            return
        }
        if isBackupEnabled {
            alertPresenter.check(
                "バックアップデータの復元",
                "バックアップ有効化中は、データの復元が行えません。\n"
                    + "バックアップの無効化後、適切なバックアップ先からデータの復元を行ってください。",
                on: self,
                { _ in self.provider.view.reloadData() }
            )
        }
        alertPresenter.yn(
            title: "復元",
            message: "データの復元を行いますか？\n現在のアプリ上のデータは上書きされます",
            on: self,
            y: { _ in
                do {
                    try strategy.restore()
                    self.alertPresenter.check(
                        "バックアップデータの復元",
                        "バックアップデータの復元を完了しました",
                        on: self,
                        { _ in }
                    )

                } catch {
                    self.alertPresenter.check(
                        "復元に失敗",
                        // TODO: エラーコードによるエラーメッセージの変化
                        "バックアップデータの復元に失敗しました: \(error)",
                        on: self,
                        { _ in }
                    )
                }
            },
            n: { _ in self.provider.view.reloadData() }
        )
    }
}
