//
//  TagListPresenter.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/06.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class TagListPresenterTest: XCTestCase {
    var tag1: Tag!
    var tag2: Tag!
    var tag3: Tag!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name

        let realm = try! Realm()
        try! realm.write {
            tag1 = Tag(name: "tag1")
            realm.add(tag1)
            tag2 = Tag(name: "tag2")
            realm.add(tag2)
            tag3 = Tag(name: "tag3")
            realm.add(tag3)
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testLoad() {
        let presenter = TagListPresenter()

        XCTAssertTrue(presenter.tags.count == 3)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))

        let realm = try! Realm()
        try! realm.write {
            realm.add(Tag(name: "tag4"))
        }

        XCTAssertTrue(presenter.tags.count == 4)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag4" }))
    }

    func testDeleteAfterLoad() {
        let presenter = TagListPresenter()

        XCTAssertTrue(presenter.tags.count == 3)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))

        let realm = try! Realm()
        try! realm.write {
            realm.delete(tag1)
            realm.delete(tag2)
        }

        XCTAssertTrue(presenter.tags.count == 1)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))
    }

    func testAddAfterLoad() {
        let presenter = TagListPresenter()

        XCTAssertTrue(presenter.tags.count == 3)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))

        let realm = try! Realm()
        try! realm.write {
            realm.add(Tag(name: "newTag"))
        }

        XCTAssertTrue(presenter.tags.count == 4)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "newTag" }))
    }

    func testUpdateAfterLoad() {
        let presenter = TagListPresenter()

        XCTAssertTrue(presenter.tags.count == 3)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag2" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))

        let realm = try! Realm()
        try! realm.write {
            tag2.name = "modifiedTag"
            realm.add(tag2, update: true)
        }

        XCTAssertTrue(presenter.tags.count == 3)
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag1" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "modifiedTag" }))
        XCTAssertTrue(presenter.tags.contains(where: { t in t.name == "tag3" }))
    }
}
