//
//  TagCollectionPresenterTest.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/06.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class TagCollectionPresenterTest: XCTestCase {
    var note1: Note!
    var note2: Note!
    var note3: Note!
    var note4: Note!
    var note5: Note!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name

        let realm = try! Realm()
        /**
         note1 : tag1
         note2 : tag1, tag2
         note3 : tag2, tag1
         note4 : tag2
         note5 :
         */
        try! realm.write {
            let tag1 = Tag(name: "tag1")
            realm.add(tag1)
            let tag2 = Tag(name: "tag2")
            realm.add(tag2)
            note1 = Note(body: "test1")
            note1.tags.append(tag1)
            realm.add(note1)
            note2 = Note(body: "test2")
            note2.tags.append(tag1)
            note2.tags.append(tag2)
            realm.add(note2)
            note3 = Note(body: "test3")
            note3.tags.append(tag2)
            note3.tags.append(tag1)
            realm.add(note3)
            note4 = Note(body: "test4")
            note4.tags.append(tag2)
            realm.add(note4)
            note5 = Note(body: "test5")
            realm.add(note5)
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoad() {
        let presenter = TagCollectionPresenter()

        XCTAssertTrue(presenter.tags.count == 2)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))

        presenter.load(noteId: note1.id)

        XCTAssertTrue(presenter.tags.count == 1)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))

        presenter.load(noteId: note2.id)

        XCTAssertTrue(presenter.tags.count == 2)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))

        presenter.load(noteId: note3.id)

        XCTAssertTrue(presenter.tags.count == 2)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))

        presenter.load(noteId: note4.id)

        XCTAssertTrue(presenter.tags.count == 1)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))

        presenter.load(noteId: note5.id)

        XCTAssertTrue(presenter.tags.count == 0)
    }

    func testDeleteAfterLoad() {
        let presenter = TagCollectionPresenter()

        XCTAssertTrue(presenter.tags.count == 2)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))

        let realm = try! Realm()
        try! realm.write {
            let tag2 = realm.object(ofType: Tag.self, forPrimaryKey: 1)!
            realm.delete(tag2)
        }

        XCTAssertTrue(presenter.tags.count == 1)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
    }

    func testAddAfterLoad() {
        let presenter = TagCollectionPresenter()

        presenter.load(noteId: note5.id)

        XCTAssertTrue(presenter.tags.count == 0)

        let realm = try! Realm()
        try! realm.write {
            let newTag = Tag(name: "newTag")
            note5.tags.append(newTag)
            realm.add(newTag)
            realm.add(note5, update: true)
        }

        XCTAssertTrue(presenter.tags.count == 1)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "newTag" }))
    }

    func testUpdateAfterLoad() {
        let presenter = TagCollectionPresenter()

        presenter.load(noteId: note4.id)

        XCTAssertTrue(presenter.tags.count == 1)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))

        let realm = try! Realm()
        try! realm.write {
            // tag2's id == 1
            let tag = realm.object(ofType: Tag.self, forPrimaryKey: 1)!
            tag.name = "newName"
            realm.add(tag, update: true)
        }

        XCTAssertTrue(presenter.tags.count == 1)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "newName" }))
    }
}
