//
//  NoteListPresenterTest.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/06.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class NoteListPresenterTest: XCTestCase {
    var tag1: Tag!
    var tag2: Tag!

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
            tag1 = Tag(name: "tag1")
            realm.add(tag1)
            tag2 = Tag(name: "tag2")
            realm.add(tag2)
            let note1 = Note(body: "test1")
            note1.tags.append(tag1)
            realm.add(note1)
            let note2 = Note(body: "test2")
            note2.tags.append(tag1)
            note2.tags.append(tag2)
            realm.add(note2)
            let note3 = Note(body: "test3")
            note3.tags.append(tag2)
            note3.tags.append(tag1)
            realm.add(note3)
            let note4 = Note(body: "test4")
            note4.tags.append(tag2)
            realm.add(note4)
            let note5 = Note(body: "test5")
            realm.add(note5)
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoad() {
        let presenter = NoteListPresenter()

        XCTAssertTrue(presenter.notes.count == 5)

        presenter.load(nil)

        XCTAssertTrue(presenter.notes.count == 5)

        presenter.load(tag1.id)

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))

        presenter.load(tag2.id)

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test4" }))
    }

    func testDeleteAfterLoad() {
        let presenter = NoteListPresenter()

        presenter.load(tag1.id)

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))

        let realm = try! Realm()

        try! realm.write {
            // note2's id == 1
            let note = realm.object(ofType: Note.self, forPrimaryKey: 1)!
            realm.delete(note)
        }

        XCTAssertTrue(presenter.notes.count == 2)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))

        try! realm.write {
            // note1's id == 0
            let note = realm.object(ofType: Note.self, forPrimaryKey: 0)!
            note.tags.removeAll()
            realm.add(note, update: true)
        }

        XCTAssertTrue(presenter.notes.count == 1)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))
    }

    func testAddAfterLoad() {
        let presenter = NoteListPresenter()

        presenter.load(tag1.id)

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))

        let realm = try! Realm()

        try! realm.write {
            // note4's id == 3
            let note = realm.object(ofType: Note.self, forPrimaryKey: 3)!
            note.tags.append(tag1)
            realm.add(note, update: true)
        }

        XCTAssertTrue(presenter.notes.count == 4)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test4" }))

        try! realm.write {
            let note = Note(body: "newNote")
            note.tags.append(tag1)
            realm.add(note)
        }

        XCTAssertTrue(presenter.notes.count == 5)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test4" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "newNote" }))
    }

    func testUpdateAfterLoad() {
        let presenter = NoteListPresenter()

        presenter.load(tag1.id)

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))

        let realm = try! Realm()

        try! realm.write {
            // note2's id == 1
            let note = realm.object(ofType: Note.self, forPrimaryKey: 1)!
            note.body = "modifiedTest"
            realm.add(note, update: true)
        }

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "modifiedTest" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))
    }
}
