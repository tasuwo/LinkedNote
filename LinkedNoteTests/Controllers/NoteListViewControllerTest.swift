//
//  NoteListViewControllerTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/07.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class NoteListViewControllerTest: XCTestCase {
    var tabVc: UITabBarController!
    var navVc: UINavigationController!
    var vc: NoteListViewController!
    var ap: FakeAlertPresenter!
    var article: Article!
    var note: Note?

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    func initViewController(withNote: Bool, withSetting setting: NodeListViewControllerSettings) {
        article = Article(localId: "", title: "", url: "", thumbnailUrl: "")
        let realm = try! Realm()
        try! realm.write {
            let api = Api(signature: "test_signature")
            let account = ApiAccount(username: "test_username")
            account.articles.append(article)
            realm.add(api)
            realm.add(account)
            realm.add(article)
            if withNote {
                note = Note(body: "test_note")
                article.notes.append(note!)
                realm.add(note!)
                realm.add(article, update: true)
            }
        }

        FakeAPIWrapper.initialize()

        ap = FakeAlertPresenter()
        vc = NoteListViewController(provider: NoteListView(), settings: setting, calculator: FakeFrameCalculator(), alertPresenter: ap)
        navVc = UINavigationController(rootViewController: vc)
        tabVc = UITabBarController()
        vc.tabBarItem = UITabBarItem(title: "アカウント", image: UIImage(named: "tabbar_icon_account"), tag: 0)
        let myTabs: [UIViewController] = [navVc]
        tabVc.setViewControllers(myTabs, animated: false)

        // Call view to execute viewDidLoad
        _ = vc.view
    }

    override func tearDown() {
        super.tearDown()
    }

    // テストできることがない...
}
