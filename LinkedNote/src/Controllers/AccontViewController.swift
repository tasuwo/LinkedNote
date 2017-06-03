//
//  AccontViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import PocketAPI

class AccountViewController: UIViewController {
    var currentActiveView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let offset = self.navigationController!.tabBarController!.tabBar.frame.height
            + self.navigationController!.navigationBar.frame.height
            + UIApplication.shared.statusBarFrame.height
        let frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height - offset)
        if PocketAPI.shared().isLoggedIn {
            let view = AccountView(frame: frame)
            view.delegate = self
            self.currentActiveView = view
            self.view.addSubview(view)
        } else {
            let view = SignInView(frame: frame)
            view.delegate = self
            self.currentActiveView = view
            self.view.addSubview(view)
        }
        
        self.navigationItem.title = "アカウント"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AccountViewController: SignInViewDelegate {
    func didTouchLoginButton() {
        PocketAPI.shared().login(handler: {(api, error) in
            if error != nil {
                // There was an error when authorizing the user.
                // The most common error is that the user denied access to your application.
                // The error object will contain a human readable error message that you
                // should display to the user. Ex: Show an UIAlertView with the message
                // from error.localizedDescription
            } else {
                // The user logged in successfully, your app can now make requests.
                // [API username] will return the logged-in user’s username
                // and API.loggedIn will == YES
                let view = AccountView(frame: self.currentActiveView!.frame)
                view.delegate = self
                self.currentActiveView?.removeFromSuperview()
                self.view.addSubview(view)
                self.currentActiveView = view
            }
        })
    }
}

extension AccountViewController: AccountViewDelegate {
    func didTouchLogOutButton() {
        PocketAPI.shared().logout()

        let view = SignInView(frame: self.currentActiveView!.frame)
        view.delegate = self
        self.currentActiveView?.removeFromSuperview()
        self.view.addSubview(view)
        self.currentActiveView = view
    }
}
