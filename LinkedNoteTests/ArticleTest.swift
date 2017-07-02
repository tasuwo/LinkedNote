//
//  ArticleTest.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class ArticleTest: XCTestCase {

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGet() {
        XCTAssertNil(Article.get(localId: "test_local_id", accountId: 0))

        let realm = try! Realm()
        try! realm.write {
            let account = ApiAccount(username: "test_username")
            let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
            account.articles.append(article)
            realm.add(account)
            realm.add(article)
        }

        let article = Article.get(localId: "test_local_id", accountId: 0)
        XCTAssertTrue(article?.localId == "test_local_id")
        XCTAssertTrue(article?.title == "test_title")
        XCTAssertTrue(article?.url == "test_url")
        XCTAssertTrue(article?.thumbnailUrl == "test_thumbnail_url")
    }

    func testAdd() {
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        try! Article.add(article)

        let realm = try! Realm()
        let result = realm.object(ofType: Article.self, forPrimaryKey: 0)
        XCTAssertTrue(result?.localId == "test_local_id")
        XCTAssertTrue(result?.title == "test_title")
        XCTAssertTrue(result?.url == "test_url")
        XCTAssertTrue(result?.thumbnailUrl == "test_thumbnail_url")
    }

    func testAddWithoutId() {
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")

        XCTAssertThrowsError(try Article.add(article)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.InvalidParameter(""))
        }
    }

    func testAddWithDupricatedId() {
        let article1 = Article(localId: "test1_local_id", title: "test1_title", url: "test1_url", thumbnailUrl: "test1_thumbnail_url")
        let article2 = Article(localId: "test2_local_id", title: "test2_title", url: "test2_url", thumbnailUrl: "test2_thumbnail_url")
        article1.addId()
        article2.addId()
        let realm = try! Realm()
        try! realm.write {
            realm.add(article1)
        }

        XCTAssertThrowsError(try Article.add(article2)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    func testAddToAccount() {
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let account = ApiAccount(username: "test_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(account)
            realm.add(article)
        }
        try! Article.add(article, to: account)

        let registeredAccount = realm.object(ofType: ApiAccount.self, forPrimaryKey: 0)
        let registeredArticle = realm.object(ofType: Article.self, forPrimaryKey: 0)
        XCTAssertNotNil(registeredAccount)
        XCTAssertNotNil(registeredArticle)
        XCTAssertTrue(registeredAccount!.username == "test_username")
        XCTAssertTrue(registeredArticle!.localId == "test_local_id")
        XCTAssertTrue(registeredArticle!.title == "test_title")
        XCTAssertTrue(registeredArticle!.url == "test_url")
        XCTAssertTrue(registeredArticle!.thumbnailUrl == "test_thumbnail_url")
        XCTAssertTrue(registeredAccount!.articles.first!.id == registeredArticle!.id)
        XCTAssertTrue(registeredArticle!.apiAccount!.id == registeredAccount!.id)
    }

    func testAddToAccountBeforeSaveArticle() {
        let account = ApiAccount(username: "test_username")
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        try! ApiAccount.add(account)

        XCTAssertThrowsError(try Article.add(article, to: account)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testAddToNotSavedAccount() {
        let account = ApiAccount(username: "test_username")
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()

        let realm = try! Realm()
        try! realm.write {
            realm.add(article)
        }

        XCTAssertThrowsError(try Article.add(article, to: account)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testAddToApiWithIntegrityConstraintViolation() {
        let account = ApiAccount(username: "test_username")
        let shared_article_local_id = "test_local_id_shared"
        let article2 = Article(localId: shared_article_local_id, title: "test2_title", url: "test2_url", thumbnailUrl: "test2_thumbnail_url")

        let realm = try! Realm()
        try! realm.write {
            let article = Article(localId: shared_article_local_id, title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
            article.addId()
            account.articles.append(article)
            realm.add(article)
            realm.add(account)

            article2.addId()
            realm.add(article2)
        }

        XCTAssertThrowsError(try Article.add(article2, to: account)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }

    func testAddToApiWithoutUpdateAccount() {
        let account = ApiAccount(username: "test_username")
        let article1 = Article(localId: "test1_local_id", title: "test1_title", url: "test1_url", thumbnailUrl: "test1_thumbnail_url")
        let article2 = Article(localId: "test2_local_id", title: "test2_title", url: "test2_url", thumbnailUrl: "test2_thumbnail_url")
        let realm = try! Realm()
        try! realm.write {
            realm.add(article1)
            realm.add(account)
        }

        XCTAssertThrowsError(try Article.add(article2, to: account)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.InvalidParameter(""))
        }
    }
}
