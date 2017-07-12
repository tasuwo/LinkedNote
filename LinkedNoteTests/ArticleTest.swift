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

    // MARK: - .get(localId:_, accountId:_)

    func testThatItReturnNilWhenTryToGetObjectByLocalIdAndRelatedAccountIdIfThereAreNoSavedObject() {
        // given
        // No objects added to database

        // then      when
        XCTAssertNil(Article.get(localId: "test_local_id", accountId: 0))
    }

    func testThatItGetObjectByLocalIdAndRelatedAccountId() throws {
        // given
        let realm = try! Realm()
        try! realm.write {
            let account = ApiAccount(username: "test_username")
            let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
            account.articles.append(article)
            realm.add(account)
            realm.add(article)
        }

        // when
        let article = try AssertNotNilAndUnwrap(Article.get(localId: "test_local_id", accountId: 0))

        // then
        XCTAssertTrue(article.localId == "test_local_id")
        XCTAssertTrue(article.title == "test_title")
        XCTAssertTrue(article.url == "test_url")
        XCTAssertTrue(article.thumbnailUrl == "test_thumbnail_url")
    }

    // MARK: - .add(_)

    func testThatItAddObject() throws {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()

        // when
        try! Article.add(article)

        // then
        let realm = try! Realm()
        let result = try AssertNotNilAndUnwrap(realm.object(ofType: Article.self, forPrimaryKey: 0))
        XCTAssertTrue(result.localId == "test_local_id")
        XCTAssertTrue(result.title == "test_title")
        XCTAssertTrue(result.url == "test_url")
        XCTAssertTrue(result.thumbnailUrl == "test_thumbnail_url")
    }

    func testThatItThrowErrorIfTryToAddObjectWithoutCallMethodForAddingId() {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")

        // when
        XCTAssertThrowsError(try Article.add(article)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.InvalidParameter(""))
        }
    }

    func testThatItThrowErrorIfTryToAddObjectWithDupricatedId() {
        // given
        // If create data model objects before saveing, those would get same ids.
        let article1 = Article(localId: "test1_local_id", title: "test1_title", url: "test1_url", thumbnailUrl: "test1_thumbnail_url")
        let article2 = Article(localId: "test2_local_id", title: "test2_title", url: "test2_url", thumbnailUrl: "test2_thumbnail_url")
        article1.addId()
        article2.addId()
        let realm = try! Realm()
        try! realm.write {
            realm.add(article1)
        }

        // when
        XCTAssertThrowsError(try Article.add(article2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    // MARK: - .add(_, to:_)

    func testThatItRelateObjectToAccount() throws {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let account = ApiAccount(username: "test_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(account)
            realm.add(article)
        }

        // when
        try! Article.add(article, to: account)

        // then
        let registeredAccount = try AssertNotNilAndUnwrap(realm.object(ofType: ApiAccount.self, forPrimaryKey: 0))
        let registeredArticle = try AssertNotNilAndUnwrap(realm.object(ofType: Article.self, forPrimaryKey: 0))
        // check params
        XCTAssertTrue(registeredAccount.username == "test_username")
        XCTAssertTrue(registeredArticle.localId == "test_local_id")
        XCTAssertTrue(registeredArticle.title == "test_title")
        XCTAssertTrue(registeredArticle.url == "test_url")
        XCTAssertTrue(registeredArticle.thumbnailUrl == "test_thumbnail_url")
        // check relation
        let art = try AssertNotNilAndUnwrap(registeredAccount.articles.first)
        let api = try AssertNotNilAndUnwrap(registeredArticle.apiAccount)
        XCTAssertTrue(art.id == registeredArticle.id)
        XCTAssertTrue(api.id == registeredAccount.id)
    }

    func testThatItThrowErrorWhenTryToRelateNotSavedObjectToAccount() {
        // given
        let account = ApiAccount(username: "test_username")
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let realm = try! Realm()
        try! realm.write {
            realm.add(account)
        }

        // when
        XCTAssertThrowsError(try Article.add(article, to: account)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItThrowErrorWhenTryToRelateObjectToNotSavedAccount() {
        // given
        let account = ApiAccount(username: "test_username")
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let realm = try! Realm()
        try! realm.write {
            realm.add(article)
        }

        // when
        XCTAssertThrowsError(try Article.add(article, to: account)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItThrowErrorWhenTrytoRelateObjectsWhichHasSameLocalIdToAccount() {
        // given
        let account = ApiAccount(username: "test_username")
        let sharedLocalId = "test_local_id_shared"

        let realm = try! Realm()
        try! realm.write {
            let article = Article(localId: sharedLocalId, title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
            article.addId()
            account.articles.append(article)
            realm.add(article)
            realm.add(account)
        }

        let duplicatedArticle = Article(localId: sharedLocalId, title: "test2_title", url: "test2_url", thumbnailUrl: "test2_thumbnail_url")
        try! realm.write {
            duplicatedArticle.addId()
            realm.add(duplicatedArticle)
        }

        // when
        XCTAssertThrowsError(try Article.add(duplicatedArticle, to: account)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }

    func testThatItThrowErrorWhenTryToRelateObjects_WhichHasSameIdButDifferentParamsFromSavedOne_toApi() throws {
        // given
        let account = ApiAccount(username: "test_username")
        let article1 = Article(localId: "test1_local_id", title: "test1_title", url: "test1_url", thumbnailUrl: "test1_thumbnail_url")
        let article2 = Article(localId: "test2_local_id", title: "test2_title", url: "test2_url", thumbnailUrl: "test2_thumbnail_url")
        let realm = try! Realm()
        try! realm.write {
            realm.add(article1)
            realm.add(account)
        }

        // when
        XCTAssertThrowsError(try Article.add(article2, to: account)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.InvalidParameter(""))
        }
    }
}
