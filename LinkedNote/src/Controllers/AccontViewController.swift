//
//  AccontViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController {
    var currentActiveView: UIView!
    let api: APIWrapper
    let calculator: FrameCalculator
    
    init(api: APIWrapper, calculator: FrameCalculator) {
        self.api = api
        self.calculator = calculator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize and add a view
        let view: UIView
        if type(of: self.api).isLoggedIn() {
            view = AccountView(frame: self.calculator.calcFrameOnTabAndNavBar(by: self))
            (view as! AccountView).delegate = self
        } else {
            view = SignInView(frame: self.calculator.calcFrameOnTabAndNavBar(by: self))
            (view as! SignInView).delegate = self
        }
        self.currentActiveView = view
        self.view.addSubview(self.currentActiveView)

        self.navigationItem.title = "アカウント"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AccountViewController: SignInViewDelegate {
    func didTouchLoginButton() {
        type(of: self.api).login(completion: { (error) in
            if let e = error {
                AlertCreater.error(e.localizedDescription, viewController: self)
                return
            }
            
            let signature = type(of: self.api).signature
            let username =  type(of: self.api).getUsername()!
            if ApiAccount.get(apiSignature: signature, username: username) == nil {
                let account = ApiAccount(username: username)
                ApiAccount.add(account)
                ApiAccount.add(account, to: Api.get(signature: signature)!)
            }
            
            let view = AccountView(frame: self.currentActiveView.frame)
            view.delegate = self
            self.currentActiveView.removeFromSuperview()
            self.view.addSubview(view)
            self.currentActiveView = view
        })
    }
}

extension AccountViewController: AccountViewDelegate {
    func didTouchLogOutButton() {
        type(of: self.api).logout()

        let view = SignInView(frame: self.currentActiveView.frame)
        view.delegate = self
        self.currentActiveView.removeFromSuperview()
        self.view.addSubview(view)
        self.currentActiveView = view
    }
}
