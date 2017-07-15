//
//  ArticleListViewControllerTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class ArticleListViewControllerTest: XCTestCase {
    var tabVc: UITabBarController!
    var navVc: UINavigationController!
    var vc: ArticleListViewController!
    var ap: FakeAlertPresenter!

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let fakeApi = Api(signature: FakeAPIWrapper.signature)
        try! Api.add(fakeApi)

        FakeAPIWrapper.initialize()

        ap = FakeAlertPresenter()
        vc = ArticleListViewController(provider: ArticleListView(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: ap)
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

    // Positive testing

    func testThatItTransitionToNoteViewWhenTouchTheNoteButton() {
        let exp = XCTestExpectation(description: "Pushed new view controller")

        CATransaction.begin()
        CATransaction.setCompletionBlock({ _ in
            XCTAssertNotNil(self.navVc.visibleViewController as? NoteViewController)
            exp.fulfill()
        })
        vc.didPressNoteButtonOnCell(Note(body: "test"))
        CATransaction.commit()

        self.wait(for: [exp], timeout: 1)
    }

    func testThatItTransitionToArticleViewWhenTouchTheTableCell() {
    }

    //    func testHandleLongPressOnTheCell() {}

    //    func testLoadImageTimings() {}

    //    func testRetrieveNewArticles() {}

    //    func testEditActionForTableViewCell() {}

    // func testCreateTableViewCell() {}

    // Negative testing

    func testDidPressNoteButtonWithNil() {
        vc.didPressNoteButtonOnCell(nil)

        XCTAssertTrue(ap.lastErrorMessage == "ノートが存在しません")
    }

    /*
     TODO: Mock presenter and write test
     func testThatItGetNewArticlesWhenPullArticleList() {
     // given
     // check current state
     }
     */
}
