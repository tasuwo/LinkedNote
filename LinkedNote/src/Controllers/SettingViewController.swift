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

    // TODO: コールバックを平坦にする
    private func loginTo(_ signature: String, _ username: String) {
        alertPresenter.yn(
            title: "ログイン",
            message: "\(signature) に \(username) としてログインしますか？",
            on: self,
            y: { _ in
                self.alertPresenter.check("", "Pocket ではアカウント切り替えがサポートされていません。\n別アカウントでログインしたい場合は、設定 > Safari > 履歴とWebサイトデータを削除 を実行して下さい。", on: self, { _ in
                    PocketAPIWrapper.logout()
                    PocketAPIWrapper.login(completion: { error in
                        if let e = error {
                            self.alertPresenter.error(e.localizedDescription, on: self)
                            return
                        }
                        self.provider.view.reloadData()
                    })
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

    func didPressBackUpButton() {
        alertPresenter.error("バックアップ設定はまだ実装されていません", on: self)
    }
}
