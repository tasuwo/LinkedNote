//
//  ArticleViewControllerTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/07.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class ArticleViewControllerTest: XCTestCase {
    var tabVc: UITabBarController!
    var navVc: UINavigationController!
    var vc: ArticleViewController!
    var ap: FakeAlertPresenter!
    var article: Article!
    var note: Note?

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    func initViewController(withNote: Bool) {
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
        vc = ArticleViewController(provider: ArticleView(), article: article, calculator: FakeFrameCalculator(), alertPresenter: ap)
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

    func testInitializeViewWithNoteView() {
        initViewController(withNote: true)

        XCTAssertTrue(self.vc.provider.noteView.text == note?.body)
    }

    func testInitializeViewWithoutNoteView() {
        initViewController(withNote: false)

        XCTAssertTrue(self.vc.provider.noteView.text == "ノートがまだ作成されていません")
    }

    func testEditNoteWithNote() {
        initViewController(withNote: true)

        let modifiedBody = "I modified note's body"
        let textView = UITextView(frame: CGRect.zero)
        textView.text = modifiedBody

        self.vc.textViewDidChange(textView)

        let realm = try! Realm()
        let n = realm.object(ofType: Note.self, forPrimaryKey: 0)!
        XCTAssertTrue(n.body == modifiedBody)
    }

    func testEditNoteWithoutNote() {
        initViewController(withNote: false)

        let modifiedBody = "I modified note's body"
        let textView = UITextView(frame: CGRect.zero)
        textView.text = modifiedBody

        self.vc.textViewDidChange(textView)

        XCTAssertTrue(ap.lastErrorMessage == "ノートの保存に失敗しました。ノートの作成に失敗している可能性があります")
        XCTAssertTrue(vc.provider.noteView.text == "")
    }

    // textView.text == nil となるような状況が再現できないので
    //    func testEditNoteWithInvalidTextView() {
    //        initViewController(withNote: false)
    //
    //        self.vc.textViewDidChange(UITextView())
    //
    //        XCTAssertTrue(ap.lastErrorMessage == "不明なエラー: テキスト情報の取得に失敗しました")
    //    }
}
