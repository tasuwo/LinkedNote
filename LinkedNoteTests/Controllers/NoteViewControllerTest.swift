//
//  NoteViewController.swift
//  LinkedNoteTests
//
//  Created by Tasuku Tozawa on 2018/02/11.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class NoteViewControllerTest: XCTestCase {
    var tabVc: UITabBarController!
    var navVc: MockNavigationController!
    var vc: NoteViewController!
    var ap: FakeAlertPresenter!
    var te: MockTagEditViewPresenter!
    var article: Article!
    var note: Note!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    func initViewControllerWithRealmSetup() {
        article = Article(localId: "", title: "", url: "", thumbnailUrl: "")
        article.addId()
        note = Note(body: "test_note")
        let realm = try! Realm()
        try! realm.write {
            let api = Api(signature: "test_signature")
            let account = ApiAccount(username: "test_username")
            account.articles.append(article)
            realm.add(api)
            realm.add(account)
            realm.add(article)
            article.notes.append(note!)
            realm.add(note!)
            realm.add(article, update: true)
        }

        initViewController()
    }

    func initViewControllerWithoutRelatedArticle() {
        note = Note(body: "test_note")
        let realm = try! Realm()
        try! realm.write {
            realm.add(note!)
        }

        initViewController()
    }

    func initViewController() {
        FakeAPIWrapper.initialize()

        ap = FakeAlertPresenter()
        te = MockTagEditViewPresenter(alertPresenter: ap)
        vc = NoteViewController(provider: NoteView(), note: note, calculator: FakeFrameCalculator(), alertPresenter: ap, tagEditViewPresenter: te)
        navVc = MockNavigationController(rootViewController: vc)
        tabVc = UITabBarController()
        vc.tabBarItem = UITabBarItem(title: "アカウント", image: UIImage(named: "tabbar_icon_account"), tag: 0)
        let myTabs: [UIViewController] = [navVc]
        tabVc.setViewControllers(myTabs, animated: false)

        // Call view to execute viewDidLoad
        _ = vc.view
    }

    // Positive testing

    func testThatItCouldTransitionToArticleView() {
        initViewControllerWithRealmSetup()
        XCTAssertTrue(navVc.pushedViewController is NoteViewController)

        vc.didPressViewArticleButton()

        XCTAssertNotNil(navVc.pushedViewController is ArticleViewController)
        XCTAssertTrue((navVc.pushedViewController as? ArticleViewController)?.article == article)
    }

    func testThatItCouldTransitionToTagEditView() {
        initViewControllerWithRealmSetup()
        XCTAssertFalse(te.isAdded)

        vc.didPressEditButton()

        XCTAssertTrue(te.isAdded)
    }

    /*
     func testThatItReloadTagsAfterTransitioningFromTagEditView() {
     }
     */

    func testThatItReloadNoteAfterTransitioningFromArticleView() {
    }

    // Negative testing

    func testThaItShowAlertIfThereAreNoArticlesToTransition() {
        initViewControllerWithoutRelatedArticle()

        vc.didPressViewArticleButton()

        XCTAssertTrue(ap.lastErrorMessage == "ノートに対応する記事の取得に失敗しました")
    }
}
