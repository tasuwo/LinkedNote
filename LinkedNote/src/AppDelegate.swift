//
//  AppDelegate.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import PocketAPI
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Set comsumer key for pocket api
        PocketAPI.shared().consumerKey = ""
        
        // window 生成
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = MainTabBarController()
            window.makeKeyAndVisible()
        }

        // WARNING: PLEASE DELETE THIS CODE BEFORE RELEASE =========================================
        if Api.all().count == 0 {
            let pocketApi = Api(signature: "pocket")
            Api.add(pocketApi)
            // api, account の登録処理は後回しにして、とりあえずは以下に username を直書きする方針をとる
            // ログインする Pocket の username を以下に直書きする
            let pocketAccount = ApiAccount(username: "")
            ApiAccount.add(pocketAccount)
            ApiAccount.add(pocketAccount, to: pocketApi)
            let tag1 = Tag(name: "test tag 1")
            Tag.add(tag1)
            let tag2 = Tag(name: "test tag 2")
            Tag.add(tag2)
        }
        // =========================================================================================
        
        configureStyling()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if PocketAPI.shared().handleOpen(url) {
            return true
        } else {
            // if you handle your own custom url-schemes, do it here
            return false
        }
    }
}

private extension AppDelegate {
    func configureStyling() {
        window?.tintColor = UIColor.myNavigationBarColor()
        
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 18)
        ]
        
        UINavigationBar.appearance().backgroundColor = UIColor.myNavigationBarColor()
        UINavigationBar.appearance().barTintColor = UIColor.myNavigationBarColor()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .blackTranslucent
    }
}

