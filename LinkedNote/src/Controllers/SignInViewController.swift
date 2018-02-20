//
//  SignInViewController.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/20.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    var provider: SignInViewProvider
    let calculator: FrameCalculator
    let alertPresenter: AlertPresenter

    // TODO: Presenter を作成しそこに移動する
    let apiRepo: Repository<Api>
    let accountRepo: Repository<ApiAccount>

    init(
        provider: SignInViewProvider,
        calculator: FrameCalculator,
        alertPresenter: AlertPresenter
    ) {
        self.provider = provider
        self.calculator = calculator
        self.alertPresenter = alertPresenter

        // TODO: Presenter を作成しそこに移動する
        self.apiRepo = Repository<Api>()
        self.accountRepo = Repository<ApiAccount>()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.provider.view.frame = self.view.frame
        self.provider.delegate = self
        self.view.addSubview(self.provider.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension SignInViewController: SignInViewDelegate {
    func didPressPocketButton(type: APIWrapper.Type) {
        type.login(completion: { error in
            if let e = error {
                self.alertPresenter.error(e.localizedDescription, on: self)
                return
            }

            let signature = type.signature
            guard let username = type.getUsername() else {
                self.alertPresenter.error("ユーザ名の取得に失敗しました", on: self)
                type.logout()
                return
            }
            guard let api = self.apiRepo.findBy(signature: signature) else {
                self.alertPresenter.error("登録されていない API です", on: self)
                type.logout()
                return
            }

            if self.accountRepo.find(apiSignature: signature, username: username) == nil {
                let account = ApiAccount(username: username)
                do {
                    try self.accountRepo.add(account)
                    try self.accountRepo.add(account, to: api)
                } catch {
                    self.alertPresenter.error("アカウントの登録に失敗しました", on: self)
                    type.logout()
                    return
                }
            }
        })
    }

    func didTouchLogOutButton() {
        // type(of: self.api).logout()
    }
}
