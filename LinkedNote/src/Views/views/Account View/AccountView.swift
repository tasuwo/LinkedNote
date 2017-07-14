//
//  Account.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol AccountViewProvider {
    var accountView: UIView { get }
    var signInView: UIView { get }

    func setAccountViewDelegate(delegate: AccountViewDelegate)
    func setSignInViewDelegate(delegate: SignInViewDelegate)
}

protocol AccountViewDelegate {
    func didTouchLogOutButton()
}

protocol SignInViewDelegate {
    func didTouchLoginButton()
}

class AccountView: UIView {
    var delegate: AccountViewDelegate?
    @IBOutlet var view_: UIView!
    @IBAction func didTouchLogOutButton(_: Any) {
        self.delegate?.didTouchLogOutButton()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("Account", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SignInView: UIView {
    var delegate: SignInViewDelegate?
    @IBOutlet var view_: UIView!
    @IBAction func didTouchLoginButton(_: Any) {
        self.delegate?.didTouchLoginButton()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("SignIn", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AccountViewProviderImpl: NSObject, AccountViewProvider {
    private var accountView_: AccountView
    private var signInView_: SignInView

    override init() {
        self.accountView_ = AccountView()
        self.signInView_ = SignInView()
    }

    var accountView: UIView {
        return self.accountView_
    }

    var signInView: UIView {
        return self.signInView_
    }

    func setAccountViewDelegate(delegate: AccountViewDelegate) {
        self.accountView_.delegate = delegate
    }

    func setSignInViewDelegate(delegate: SignInViewDelegate) {
        self.signInView_.delegate = delegate
    }
}
