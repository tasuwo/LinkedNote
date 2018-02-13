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

    class FakeTableView: ArticleListTableView {
        var lastDequeuedCell: ArticleListCustomCell!

        override func dequeueReusableCell(withIdentifier _: String, for _: IndexPath) -> UITableViewCell {
            lastDequeuedCell = ArticleListCustomCell()
            lastDequeuedCell.noteButton = UIButton()
            lastDequeuedCell.label = UILabel()
            lastDequeuedCell.expr = UILabel()
            return lastDequeuedCell
        }
    }

    class FakeErrorHandler: PresenterErrorHandler {
        var lastOccurredError: Error?
        func occured(_ error: Error) {
            lastOccurredError = error
        }
    }

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        self.apiWrapper = FakeAPIWrapper()

        FakeAPIWrapper.signature = "test_api"
        FakeThumbnailDownloader.willExecuteHandler = true
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitializeProperties() {
        // given
        let unitNum = 5

        // when
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)

        // then
        XCTAssertTrue(apiWrapper.unitNum == unitNum)
    }

    func testInitOffset() {
        // given
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)
        apiWrapper.offset = 1

        // when
        self.presenter.initOffset()

        // then
        XCTAssertTrue(apiWrapper.offset == 0)
    }

    func testRetrieve() {
        // given
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)
        // Setup fake observer
        let observer = FakeArticleListPresenterObserver()
        self.presenter.observer = observer
        // Articles that will be retrieved
        let articles = [
            Article(localId: "0", title: "test", url: "", thumbnailUrl: ""),
            Article(localId: "1", title: "test1", url: "", thumbnailUrl: ""),
            Article(localId: "2", title: "test2", url: "", thumbnailUrl: ""),
        ]
        apiWrapper.articles = articles
        XCTAssertTrue(self.presenter.articles.isEmpty)
        XCTAssertFalse(observer.isLoaded)

        // when
        presenter.retrieve()

        // then
        XCTAssertTrue(presenter.articles == articles)
        XCTAssertTrue(observer.isLoaded)
    }

    func testArchiveRow() {
        // given
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)
        var articles = [
            Article(localId: "0", title: "test", url: "", thumbnailUrl: ""),
            Article(localId: "1", title: "test1", url: "", thumbnailUrl: ""),
            Article(localId: "2", title: "test2", url: "", thumbnailUrl: ""),
        ]
        self.presenter.articles = articles
        XCTAssertNil(apiWrapper.lastArchivedId)

        // when
        let archievedId = "test_id"
        let indexPathRow = 2
        let indexPath = IndexPath(row: indexPathRow, section: 0)
        self.presenter.archiveRow(at: indexPath, id: archievedId)

        // then
        XCTAssertNotNil(apiWrapper.lastArchivedId,
                        "Archiving process at ApiWrapper didn't executed.")
        XCTAssertTrue(apiWrapper.lastArchivedId == archievedId)
        articles.remove(at: 2)
        XCTAssertTrue(self.presenter.articles == articles)
    }

    func testThatItDownloadThumbnail() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "fake url")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        FakeThumbnailDownloader.willExecuteHandler = true
        XCTAssertNil(targetArticle.thumbnail)

        // when
        let tableView = UITableView(frame: CGRect.zero)
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        // then
        XCTAssertNotNil(targetArticle.thumbnail)
        XCTAssertNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])
    }

    func testThatItDownloadThumbanilAndSaveProgress() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "fake url")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        // Download won't complete. So this case could simulate the process in progress
        FakeThumbnailDownloader.willExecuteHandler = false
        XCTAssertNil(targetArticle.thumbnail)

        // when
        let tableView = UITableView(frame: CGRect.zero)
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        // then
        XCTAssertNil(targetArticle.thumbnail)
        XCTAssertNotNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])
    }

    func testThatItDoesNotDownloadThumbnailIfTheThumbnailUrlIsEmpty() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        // Download won't complete. So this case could simulate the process in progress
        FakeThumbnailDownloader.willExecuteHandler = false
        XCTAssertNil(targetArticle.thumbnail)

        // when
        let tableView = UITableView(frame: CGRect.zero)
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        // when
        XCTAssertNil(targetArticle.thumbnail)
        XCTAssertNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])
    }

    func testThatItBlockTheNewDownloadingIfPreviousDownloadingInProgress() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        FakeThumbnailDownloader.willExecuteHandler = true
        XCTAssertNil(targetArticle.thumbnail)
        // Set up fake downloader
        let inProgressDownloader: FakeThumbnailDownloader = FakeThumbnailDownloader(article: targetArticle, handler: { _ in })
        inProgressDownloader.key = "in progress"
        self.presenter.thumbnailDownloadersInProgress[targetIndexPath] = inProgressDownloader

        // when
        let tableView = UITableView(frame: CGRect.zero)
        self.presenter.startThumbnailDownload(article: targetArticle, forIndexPath: targetIndexPath, tableView: tableView)

        // when
        XCTAssertNil(targetArticle.thumbnail)
        XCTAssertNotNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath])
        XCTAssertTrue(
            (self.presenter.thumbnailDownloadersInProgress[targetIndexPath] as! FakeThumbnailDownloader).key
                == "in progress")
    }

    func testThatItStartThumbnailDownloadWhenTheCellInsertedToTableView() {
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "fake url")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        // Download won't complete. So we could check if the download process started or not.
        FakeThumbnailDownloader.willExecuteHandler = false
        // Insert cell to use the thumbnail view size (if not prepare this, thumbnail's view will be nil and error occurred
        let tableView = FakeTableView()
        tableView.beginUpdates()
        tableView.insertRows(at: [targetIndexPath], with: .none)
        tableView.endUpdates()

        // when
        _ = self.presenter.tableView(tableView, cellForRowAt: targetIndexPath)

        // then
        XCTAssertNil(targetArticle.thumbnail)
        XCTAssertNotNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath],
                        "Thumbnail downloading process wasn't started even thoug it hasn't download yet.")
    }

    func testThatItDoesNotStartThumbnailDownloadWhenTheCellInsertedToTableViewIfThumbnailWasAlreadyLoaded() {
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "", url: "", thumbnailUrl: "fake url")
        // Thumbnail is already downloaded
        targetArticle.thumbnail = UIImage()
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        // Download won't complete. So we could check if the download process started or not.
        FakeThumbnailDownloader.willExecuteHandler = false

        // when
        _ = self.presenter.tableView(FakeTableView(), cellForRowAt: targetIndexPath)

        // then
        XCTAssertNotNil(targetArticle.thumbnail)
        XCTAssertNil(self.presenter.thumbnailDownloadersInProgress[targetIndexPath],
                     "Thumbnail downloading process was started even though it already downloaded.")
    }

    func testThatItFillInformationToCellWhenTheCellInsertedToTableView() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "a", url: "b", thumbnailUrl: "fake url")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        let tableView = FakeTableView()

        // when
        _ = self.presenter.tableView(tableView, cellForRowAt: targetIndexPath)

        // then
        XCTAssertTrue(tableView.lastDequeuedCell.article == targetArticle)
        XCTAssertTrue(tableView.lastDequeuedCell.expr.text == targetArticle.excerpt)
        XCTAssertTrue(tableView.lastDequeuedCell.label.text == targetArticle.title)
    }

    func testThatItEnableNoteButtonOnCellIfNoteBindedToArticle() {
        // given
        let targetArticle = Article(localId: "1", title: "a", url: "b", thumbnailUrl: "fake url")
        // Bind note to article
        let targetNote = Note(body: "c")
        targetArticle.notes.append(targetNote)
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        let tableView = FakeTableView()

        // when
        _ = self.presenter.tableView(tableView, cellForRowAt: targetIndexPath)

        // then
        XCTAssertTrue(tableView.lastDequeuedCell.noteButton.isEnabled)
        XCTAssertTrue(tableView.lastDequeuedCell.noteButton.currentImage == UIImage(named: "note_enable"))
    }

    func testThatItDisableNoteButtonOnCellIfNoteDoesNotBindedToArticle() {
        // given
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
        let targetArticle = Article(localId: "1", title: "a", url: "b", thumbnailUrl: "fake url")
        let targetIndexPath = IndexPath(row: 0, section: 0)
        self.presenter.articles = [targetArticle]
        let tableView = FakeTableView()

        // when
        _ = self.presenter.tableView(tableView, cellForRowAt: targetIndexPath)

        // then
        XCTAssertFalse(tableView.lastDequeuedCell.noteButton.isEnabled)
        XCTAssertTrue(tableView.lastDequeuedCell.noteButton.currentImage == UIImage(named: "note_disable"))
    }

    func testThatItSendErrorNotificationToHandlerIfErrorOccurredAtRetrieving() {
        // given
        let unitNum = 5
        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: unitNum)
        // Setup fake observer
        let observer = FakeArticleListPresenterObserver()
        self.presenter.observer = observer
        // Articles that will be retrieved
        let articles = [
            Article(localId: "0", title: "test", url: "", thumbnailUrl: ""),
            Article(localId: "1", title: "test1", url: "", thumbnailUrl: ""),
            Article(localId: "2", title: "test2", url: "", thumbnailUrl: ""),
        ]
        apiWrapper.articles = articles
        XCTAssertTrue(self.presenter.articles.isEmpty)
        XCTAssertFalse(observer.isLoaded)
        // Setup fake error handler (controller)
        FakeAPIWrapper.willErrorAtRetrieve = true
        FakeAPIWrapper.errorAtRetrieve = PocketAPIWrapperError.NotLoggedIn
        let handler = FakeErrorHandler()
        self.presenter.errorObserver = handler
        XCTAssertNil(handler.lastOccurredError)

        // when
        presenter.retrieve()

        // then
        XCTAssertTrue(self.presenter.articles.isEmpty)
        XCTAssertFalse(observer.isLoaded)
        XCTAssertNotNil(handler.lastOccurredError)
        XCTAssertTrue(handler.lastOccurredError! == PocketAPIWrapperError.NotLoggedIn)
    }
}
