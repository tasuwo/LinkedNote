//
//  ArticleListViewControllerTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class ArticleListViewControllerTest: XCTestCase {
    var tabVc: UITabBarController!
    var navVc: UINavigationController!
    var vc: ArticleListViewController!
    var ap: FakeAlertPresenter!

    class MockArticleTableView: UITableView {
        var mockedArticle: Article!
        var returnedCell: ArticleListCustomCell!

        override func cellForRow(at _: IndexPath) -> UITableViewCell? {
            let cell = ArticleListCustomCell()
            cell.article = self.mockedArticle
            cell.noteButton = UIButton()

            self.returnedCell = cell
            return cell
        }
    }

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let fakeApi = Api(signature: FakeAPIWrapper.signature)
        // TODO: Repository に依存させない
        try! Repository<Api>().add(fakeApi)

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

    func testThatItStoreNewArticleAndNewNoteWithBindingsWhenTouchTheTableCell() throws {
        // given
        FakeAPIWrapper.username = "tasuwo"
        let realm = try! Realm()
        try! realm.write {
            let account = ApiAccount(username: "tasuwo")
            realm.add(account)
            let registeredAccount = realm.object(ofType: ApiAccount.self, forPrimaryKey: 0)!

            let api = Api(signature: FakeAPIWrapper.signature)
            api.accounts.append(registeredAccount)
            realm.add(api)
        }
        let article = Article(localId: "1", title: "a", url: "b", thumbnailUrl: "c")
        let mockTableView = MockArticleTableView()
        mockTableView.mockedArticle = article
        XCTAssertNil(mockTableView.returnedCell)

        // when
        vc.tableView(mockTableView, didSelectRowAt: IndexPath(item: 0, section: 0))

        // then
        // Save new article
        let result = try AssertNotNilAndUnwrap(realm.object(ofType: Article.self, forPrimaryKey: 0))
        XCTAssertTrue(result.id == 0)
        XCTAssertTrue(result.localId == "1")
        XCTAssertTrue(result.title == "a")
        XCTAssertTrue(result.url == "b")
        XCTAssertTrue(result.thumbnailUrl == "c")
        // Bind article to api account
        let account = try AssertNotNilAndUnwrap(realm.object(ofType: ApiAccount.self, forPrimaryKey: 0))
        XCTAssertNotNil(account.articles.first)
        XCTAssertTrue(account.articles.endIndex == 1)
        XCTAssertTrue(account.articles.first == result)
        XCTAssertTrue(result.apiAccount == account)
        // Create new note
        let note = try AssertNotNilAndUnwrap(realm.object(ofType: Note.self, forPrimaryKey: 0))
        XCTAssertTrue(note.body == "")
        // Bind note to article
        XCTAssertNotNil(result.note)
        XCTAssertTrue(result.note == note)
        XCTAssertTrue(note.article == result)
        // Add article to cell
        XCTAssertNotNil(mockTableView.returnedCell)
        XCTAssertNotNil(mockTableView.returnedCell.article)
        XCTAssertNotNil(mockTableView.returnedCell.article == result)
    }

    //    func testThatItTransitionToArticleViewWhenTouchTheTableCell() {}

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
