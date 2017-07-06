//
//  NoteListPresenterTest.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/06.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class NoteListPresenterTest: XCTestCase {
    var apiWrapper: FakeAPIWrapper!
    var presenter: NoteListPresenter!
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
        self.presenter = NoteListPresenter()

        XCTAssertTrue(presenter.notes.isEmpty)

        self.presenter.load(nil)

        XCTAssertTrue(presenter.notes.count == 5)

        self.presenter.load(tag1.id)

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test1" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))

        self.presenter.load(tag2.id)

        XCTAssertTrue(presenter.notes.count == 3)
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test2" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test3" }))
        XCTAssertTrue(presenter.notes.contains(where: { n in n.body == "test4" }))
    }
}
