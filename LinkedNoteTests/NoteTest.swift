//
//  NoteTest.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class NoteTest: XCTestCase {
    private let repo = Repository<Note>()

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - .findBy(signature:_, username:_, article:_)

    func testThatItReturnNilWhenGetObjectByMetaInformationsIfThereAreNoTargetObject() {
        // given
        let article = Article(
            localId: "test_local_id",
            title: "test_title",
            url: "test_url",
            thumbnailUrl: "test_thumbnail_url")

        // then      when
        XCTAssertNil(repo.findBy(
            signature: "test_signature",
            username: "test_username",
            article: article))
    }

    func testThatItGetObjectByMetaInformations() throws {
        let api = Api(signature: "test_signature")
        let account = ApiAccount(username: "test_usename")
        let article = Article(
            localId: "test_local_id",
            title: "test_title",
            url: "test_url",
            thumbnailUrl: "test_thumbnail_url")
        article.addId()

        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            article.notes.append(note)
            account.articles.append(article)
            api.accounts.append(account)
            realm.add(api)
            realm.add(account)
            realm.add(article)
            realm.add(note)
        }

        let result = try AssertNotNilAndUnwrap(repo.findBy(
            signature: api.signature,
            username: account.username,
            article: article))
        XCTAssertTrue(result.body == "test_note")
    }

    // MARK: - .findBy(accountId:_, articleLocalId:_)

    func testThatItReturnNilWhenTryToGetObjectByAccountIdAndLocalIdIfThereAreNoTargetObject() {
        // given
        // No objects saved

        // then      when
        XCTAssertNil(repo.findBy(accountId: 0, articleLocalId: "test_local_id"))
    }

    func testThatItGetObjectByAccountIdAndLocalId() throws {
        let account = ApiAccount(username: "test_usename")
        let article = Article(
            localId: "test_local_id",
            title: "test_title",
            url: "test_url",
            thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            article.notes.append(note)
            account.articles.append(article)
            realm.add(account)
            realm.add(article)
            realm.add(note)
        }

        let result = try AssertNotNilAndUnwrap(repo.findBy(
            accountId: account.id,
            articleLocalId: article.localId))
        XCTAssertTrue(result.body == "test_note")
    }

    // MARK: - .findBy(tagId:_)

    func testThatItOccurNoErrorAndGetemptyResultWhenTryToGetObjectByTagIdIfThereAreNoTargetObject() {
        // given
        // No objects saved

        // when
        let result = repo.findBy(tagId: 0)

        // then
        XCTAssertTrue(result.count == 0)
    }

    func testThatItGetObjectByTagId() throws {
        // given
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")
        let realm = try! Realm()
        try! realm.write {
            note.tags.append(tag)
            realm.add(tag)
            realm.add(note)
        }

        // when
        let result = try AssertNotNilAndUnwrap(repo.findBy(tagId: tag.id))

        // then
        XCTAssertTrue(result.count == 1)
        let savedNote = try AssertNotNilAndUnwrap(result.first)
        XCTAssertTrue(savedNote.body == "test_note")
    }

    // MARK: - .add(_)

    func testThatItAddObject() throws {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let note = Note(body: "test_note")

        // when
        try! repo.add(note)

        // then
        let realm = try! Realm()
        let result = try AssertNotNilAndUnwrap(realm.object(ofType: Note.self, forPrimaryKey: 0))
        XCTAssertTrue(result.body == "test_note")
    }

    func testThatItThrowErrorIfTryToAddObjectWithDupricatedId() {
        // given
        let note1 = Note(body: "test_note1")
        let note2 = Note(body: "test_note2")
        let realm = try! Realm()
        try! realm.write {
            realm.add(note1)
        }

        // when
        XCTAssertThrowsError(try repo.add(note2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    // MARK: - .add(_, to:_)

    func testThatItRelateNoteToArticle() throws {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let note = Note(body: "test_note")
        let realm = try! Realm()
        try! realm.write {
            realm.add(article)
            realm.add(note)
        }

        // when
        try! repo.add(note, to: article)

        // then
        let registeredNote = try AssertNotNilAndUnwrap(realm.object(ofType: Note.self, forPrimaryKey: note.id))
        let registeredArticle = try AssertNotNilAndUnwrap(realm.object(ofType: Article.self, forPrimaryKey: article.id))
        XCTAssertTrue(registeredNote.body == "test_note")
        XCTAssertTrue(registeredArticle.localId == "test_local_id")
        XCTAssertTrue(registeredArticle.title == "test_title")
        XCTAssertTrue(registeredArticle.url == "test_url")
        XCTAssertTrue(registeredArticle.thumbnailUrl == "test_thumbnail_url")
        // check relation
        let articleRelatedToRegisteredNote = try AssertNotNilAndUnwrap(registeredNote.article)
        let noteRelatedToRegisteredArticle = try AssertNotNilAndUnwrap(registeredArticle.note)
        XCTAssertTrue(articleRelatedToRegisteredNote.id == registeredArticle.id)
        XCTAssertTrue(noteRelatedToRegisteredArticle.id == registeredNote.id)
    }

    func testThatItThrowErrorIfTryToRelateNotSavedNoteToArticle() {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let note = Note(body: "test_note")
        let realm = try! Realm()
        try! realm.write {
            realm.add(article)
        }

        // when
        XCTAssertThrowsError(try repo.add(note, to: article)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItThrowErrorIfTryToRelateNoteToNotSavedArticle() {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            realm.add(note)
        }

        // when
        XCTAssertThrowsError(try repo.add(note, to: article)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItThrowErrorWhenTryToAddMultipleNotesToOneArticle() {
        // given
        let article = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article.addId()
        let note1 = Note(body: "test_note1")

        let realm = try! Realm()
        try! realm.write {
            article.notes.append(note1)
            realm.add(article)
            realm.add(note1)
        }

        let note2 = Note(body: "test_note2")
        try! realm.write {
            realm.add(note2)
        }

        // when
        XCTAssertThrowsError(try repo.add(note2, to: article)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }

    func testThatItThrowErrorWhenTryToAddOneNoteToMultipleArticles() {
        // given
        let note = Note(body: "test_note1")
        let article1 = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article1.addId()

        let realm = try! Realm()
        try! realm.write {
            article1.notes.append(note)
            realm.add(article1)
            realm.add(note)
        }

        let article2 = Article(localId: "test_local_id", title: "test_title", url: "test_url", thumbnailUrl: "test_thumbnail_url")
        article2.addId()
        try! realm.write {
            realm.add(article2)
        }

        // when
        XCTAssertThrowsError(try repo.add(note, to: article2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }
}
