//
//  AppDelegate.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import RealmSwift
import Keys
import PocketAPI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Set comsumer key for pocket api
        let keys = LinkedNoteKeys()
        PocketAPI.shared().consumerKey = keys.pocketAPIConsumerKey

        // window 生成
        window = UIWindow(frame: UIScreen.main.bounds)
        if let window = window {
            window.rootViewController = MainTabBarController()
            window.makeKeyAndVisible()
        }

        // WARNING: PLEASE DELETE THIS CODE BEFORE RELEASE =========================================
        if Api.all().count == 0 {
            let pocketApi = Api(signature: "pocket")
            try! Api.add(pocketApi)
            let tag1 = Tag(name: "test tag 1")
            try! Tag.add(tag1)
            let tag2 = Tag(name: "test tag 2")
            try! Tag.add(tag2)
        }
        // =========================================================================================

        configureStyling()

        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
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
            NSFontAttributeName: UIFont.systemFont(ofSize: 18),
        ]

        UINavigationBar.appearance().backgroundColor = UIColor.myNavigationBarColor()
        UINavigationBar.appearance().barTintColor = UIColor.myNavigationBarColor()
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barStyle = .blackTranslucent
    }
}
