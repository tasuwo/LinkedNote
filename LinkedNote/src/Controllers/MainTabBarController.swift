//
//  MainTabViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    var articleListVC: ArticleListViewController!
    var noteListVC: NoteListViewController!
    var tagListVC: TagListViewController!
    var settingVC: SettingViewController!

    var articleListNVC: UINavigationController!
    var noteListNVC: UINavigationController!
    var tagListNVC: UINavigationController!
    var settingNVC: UINavigationController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // tabbar の hide 時に黒背景がうくので、リストビューと同様の白背景にする
        self.view.backgroundColor = .white

        // WARNING: for debug ================================================
        let api = PocketAPIWrapper()
        let settings = NodeListViewControllerSettings(title: "", tagId: nil)
        let calculator = FrameCalculatorImplement()
        let alertPresenter = AlertPresenterImplement()
        //====================================================================

        self.articleListVC = ArticleListViewController(provider: ArticleListView(), api: api, calculator: calculator, alertPresenter: alertPresenter)
        self.noteListVC = NoteListViewController(provider: NoteListView(), settings: settings, calculator: calculator, alertPresenter: alertPresenter)
        self.tagListVC = TagListViewController(calculator: calculator, alertPresenter: alertPresenter)
        self.settingVC = SettingViewController(provider: SettingView(), presenter: SettingViewPresenter(), calculator: calculator, alertPresenter: alertPresenter)

        self.articleListNVC = UINavigationController(rootViewController: articleListVC)
        self.noteListNVC = UINavigationController(rootViewController: noteListVC)
        self.tagListNVC = UINavigationController(rootViewController: tagListVC)
        self.settingNVC = UINavigationController(rootViewController: settingVC)

        self.articleListNVC.navigationBar.isTranslucent = false
        self.noteListNVC.navigationBar.isTranslucent = false
        self.tagListNVC.navigationBar.isTranslucent = false
        self.settingNVC.navigationBar.isTranslucent = false

        articleListVC.tabBarItem = UITabBarItem(title: "マイリスト", image: UIImage(named: "tabbar_icon_mylist"), tag: 0)
        noteListVC.tabBarItem = UITabBarItem(title: "ノート", image: UIImage(named: "note_enable"), tag: 1)
        tagListVC.tabBarItem = UITabBarItem(title: "タグ", image: UIImage(named: "tabbar_icon_tag"), tag: 1)
        settingVC.tabBarItem = UITabBarItem(title: "アカウント", image: UIImage(named: "tabbar_icon_account"), tag: 2)

        let myTabs: [UIViewController] = [self.articleListNVC, self.noteListNVC, self.tagListNVC, self.settingNVC]
        self.setViewControllers(myTabs, animated: false)

        self.tabBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
