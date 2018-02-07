//
//  ArticleListPresenterTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/05.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class ArticleListPresenterTest: XCTestCase {
    var apiWrapper: FakeAPIWrapper!
    var presenter: ArticleListPresenter<FakeThumbnailDownloader>!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let api = Api(signature: "test_api")
        let account = ApiAccount(username: "test_username")
        api.accounts.append(account)
        let article1 = Article(localId: "1", title: "article1", url: "", thumbnailUrl: "")
        let article2 = Article(localId: "2", title: "article1", url: "", thumbnailUrl: "")
        account.articles.append(article1)
        account.articles.append(article2)

        let realm = try! Realm()
        try! realm.write {
            article1.addId()
            realm.add(article1)
            article2.addId()
            realm.add(article2)
            realm.add(account)
            realm.add(api)
        }

        self.apiWrapper = FakeAPIWrapper()
        FakeAPIWrapper.signature = "test_api"
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializeProperties() {
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)
        XCTAssertTrue(apiWrapper.unitNum == unitNum)
    }

    func testInitOffset() {
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)
        apiWrapper.offset = 1

        XCTAssertTrue(apiWrapper.offset == 1)
        self.presenter.initOffset()
        XCTAssertTrue(apiWrapper.offset == 0)
    }

    func testRetrieve() {
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)

        let observer = FakeArticleListPresenterObserver()
        self.presenter.observer = observer

        let articles = [
            Article(localId: "0", title: "test", url: "", thumbnailUrl: ""),
            Article(localId: "1", title: "test1", url: "", thumbnailUrl: ""),
            Article(localId: "2", title: "test2", url: "", thumbnailUrl: ""),
        ]
        apiWrapper.articles = articles

        XCTAssertTrue(self.presenter.articles.isEmpty)
        XCTAssertFalse(observer.isLoaded)

        presenter.retrieve()

        XCTAssertTrue(presenter.articles == articles)
        XCTAssertTrue(observer.isLoaded)
    }

    func testArchiveRow() {
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)
        var articles = [
            Article(localId: "0", title: "test", url: "", thumbnailUrl: ""),
            Article(localId: "1", title: "test1", url: "", thumbnailUrl: ""),
            Article(localId: "2", title: "test2", url: "", thumbnailUrl: ""),
        ]
        self.presenter.articles = articles

        XCTAssertNil(apiWrapper.lastArchivedId)

        let archievedId = "test_id"
        let indexPathRow = 2
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        self.presenter.archiveRow(at: indexPath, id: archievedId)

        XCTAssertNotNil(apiWrapper.lastArchivedId)
        XCTAssertTrue(apiWrapper.lastArchivedId == archievedId)
        articles.remove(at: indexPathRow)
        XCTAssertTrue(self.presenter.articles == articles)
    }

    func testThatItDownloadThumbnailOfArticle() {
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "fake url")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        FakeThumbnailDownloader.willExecuteHandler = true

        XCTAssertNil(targetArticle.thumbnail)

        let tableView = UITableView(frame: CGRect.zero)
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        XCTAssertNotNil(targetArticle.thumbnail)
        XCTAssertNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])
    }

    func testThatItDoesNotDownloadThumbnailIfTheThumbnailUrlIsEmpty() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]

        XCTAssertNil(targetArticle.thumbnail)

        let tableView = UITableView(frame: CGRect.zero)

        // when
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        // when
        XCTAssertNil(targetArticle.thumbnail)
        XCTAssertNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])
    }

    func testThatItBlockDownloadIfTheDownloadForTheImageIsAlreadyInProgress() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "fake url")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        // Download won't complete
        FakeThumbnailDownloader.willExecuteHandler = false
        // check post condition
        XCTAssertNil(targetArticle.thumbnail)
        let tableView = UITableView(frame: CGRect.zero)

        // when
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        // then
        XCTAssertNil(targetArticle.thumbnail)
        XCTAssertNotNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])

        // TODO: test with async download start/finish
    }

    func testThetItDoesNotBlockDownloadIfTheThumbnailUrlIsEmpty() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        // Download won't complete
        FakeThumbnailDownloader.willExecuteHandler = false
        // check post condition
        XCTAssertNil(targetArticle.thumbnail)
        let tableView = UITableView(frame: CGRect.zero)

        // when
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        // then
        XCTAssertNil(targetArticle.thumbnail)
        XCTAssertNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])

        // TODO: test with async download start/finish
    }

    // Cannot testing because of table view dependency
    // func loadImagesForOnscreenRows() {}
}
