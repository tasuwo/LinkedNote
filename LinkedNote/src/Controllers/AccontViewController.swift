//
//  AccontViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    let provider: AccountViewProvider
    let api: APIWrapper
    let calculator: FrameCalculator
    let alertPresenter: AlertPresenter
    var currentActiveView: UIView!

    init(provider: AccountViewProvider, api: APIWrapper, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.provider = provider
        self.api = api
        self.calculator = calculator
        self.alertPresenter = alertPresenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize and add a view
        self.provider.setSignInViewDelegate(delegate: self)
        self.provider.setAccountViewDelegate(delegate: self)

        let frame = self.calculator.calcFrameOnNavVar(by: self)
        self.provider.accountView.frame = frame
        self.provider.signInView.frame = frame

        let view: UIView
        if type(of: self.api).isLoggedIn() {
            view = self.provider.accountView
        } else {
            view = self.provider.signInView
        }
        self.currentActiveView = view
        self.view.addSubview(self.currentActiveView)

        self.navigationItem.title = "アカウント"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    fileprivate func transitionTo(_ view: UIView) {
        self.currentActiveView.removeFromSuperview()
        self.view.addSubview(view)
        self.currentActiveView = view
    }
}

extension AccountViewController: SignInViewDelegate {
    func didTouchLoginButton() {
        type(of: self.api).login(completion: { error in
            if let e = error {
                self.alertPresenter.error(e.localizedDescription, on: self)
                return
            }

            let signature = type(of: self.api).signature
            let optionalUsername = type(of: self.api).getUsername()
            guard let username = optionalUsername else {
                self.alertPresenter.error("ユーザ名の取得に失敗しました", on: self)
                type(of: self.api).logout()
                return
            }
            guard let api = Api.get(signature: signature) else {
                self.alertPresenter.error("登録されていない API です", on: self)
                type(of: self.api).logout()
                return
            }

            if ApiAccount.get(apiSignature: signature, username: username) == nil {
                let account = ApiAccount(username: username)
                do {
                    try ApiAccount.add(account)
                    try ApiAccount.add(account, to: api)
                } catch {
                    self.alertPresenter.error("アカウントの登録に失敗しました", on: self)
                    type(of: self.api).logout()
                    return
                }
            }

            self.transitionTo(self.provider.accountView)
        })
    }
}

extension AccountViewController: AccountViewDelegate {
    func didTouchLogOutButton() {
        type(of: self.api).logout()
        self.transitionTo(self.provider.signInView)
    }
}
