//
//  TagTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/05.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class TagTest: XCTestCase {

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetAll() {
        XCTAssertTrue(Tag.getAll().count == 0)

        let realm = try! Realm()
        try! realm.write {
            realm.add(Tag(name: "test_tag1"))
            realm.add(Tag(name: "test_tag2"))
        }

        let tags = Tag.getAll()
        XCTAssertTrue(tags.count == 2)
        XCTAssertTrue(tags.contains(where: { t in t.name == "test_tag1" }))
        XCTAssertTrue(tags.contains(where: { t in t.name == "test_tag2" }))
    }

    func testGetById() {
        XCTAssertNil(Tag.get(0))

        let realm = try! Realm()
        try! realm.write {
            realm.add(Tag(name: "test_tag1"))
        }

        let tag = Tag.get(0)
        XCTAssertNotNil(tag)
        XCTAssertTrue(tag?.name == "test_tag1")
    }

    func testGetByNoteId() {
        XCTAssertTrue(Tag.get(noteId: 0).count == 0)

        let realm = try! Realm()
        try! realm.write {
            let note = Note(body: "test_note")
            let tag1 = Tag(name: "test_tag1")
            note.tags.append(tag1)
            realm.add(tag1)
            let tag2 = Tag(name: "test_tag2")
            note.tags.append(tag2)
            realm.add(tag2)
            realm.add(note)
        }

        let result = Tag.get(noteId: 0)
        XCTAssertTrue(result.count == 2)
        XCTAssertTrue(result.contains(where: { t in t.name == "test_tag1" }))
        XCTAssertTrue(result.contains(where: { t in t.name == "test_tag2" }))
    }

    func testAdd() {
        let tag = Tag(name: "test_tag")

        try! Tag.add(tag)

        let realm = try! Realm()
        let result = realm.object(ofType: Tag.self, forPrimaryKey: 0)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.name == "test_tag")
    }

    func testAddWithDupricatedId() {
        let tag1 = Tag(name: "test_tag1")
        let tag2 = Tag(name: "test_tag2")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag1)
        }

        XCTAssertThrowsError(try Tag.add(tag2)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    func testAddToNote() {
        let note = Note(body: "test_note")
        let tag = Tag(name: "test_tag")

        let realm = try! Realm()
        try! realm.write {
            realm.add(note)
            realm.add(tag)
        }

        try! Tag.add(tag, to: note)

        let registeredNote = realm.object(ofType: Note.self, forPrimaryKey: 0)
        let registeredTag = realm.object(ofType: Tag.self, forPrimaryKey: 0)
        XCTAssertNotNil(registeredNote)
        XCTAssertNotNil(registeredTag)
        XCTAssertTrue(registeredNote?.body == "test_note")
        XCTAssertTrue(registeredTag?.name == "test_tag")
        XCTAssertTrue(registeredNote!.tags.contains(where: {
            t in t.isEqual(registeredTag!)
        }))
        XCTAssertTrue(registeredTag!.notes.contains(where: {
            n in n.isEqual(registeredNote!)
        }))
    }

    func testAddToNoteWithoutSavedTag() {
        let note = Note(body: "test_note")
        let tag = Tag(name: "test_tag")

        let realm = try! Realm()
        try! realm.write {
            realm.add(note)
        }

        XCTAssertThrowsError(try Tag.add(tag, to: note)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testAddToNoteWithoutSavedNote() {
        let note = Note(body: "test_note")
        let tag = Tag(name: "test_tag")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag)
        }

        XCTAssertThrowsError(try Tag.add(tag, to: note)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testDelete() {
        let tag = Tag(name: "test_tag")
        XCTAssertNoThrow(Tag.delete(tag))

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag)
        }

        XCTAssertNotNil(realm.object(ofType: Tag.self, forPrimaryKey: 0))
        Tag.delete(tag)
        XCTAssertNil(realm.object(ofType: Tag.self, forPrimaryKey: 0))
    }

    func testDeleteFromNote() {
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            note.tags.append(tag)
            realm.add(tag)
            realm.add(note)
        }

        var registeredTag = realm.object(ofType: Tag.self, forPrimaryKey: 0)
        var registeredNote = realm.object(ofType: Note.self, forPrimaryKey: 0)
        XCTAssertTrue(registeredTag!.notes.contains(where: {
            n in n.isEqual(note)
        }))
        XCTAssertTrue(registeredNote!.tags.contains(where: {
            t in t.isEqual(tag)
        }))

        try! Tag.delete(tag.id, from: note.id)

        registeredTag = realm.object(ofType: Tag.self, forPrimaryKey: 0)
        registeredNote = realm.object(ofType: Note.self, forPrimaryKey: 0)
        XCTAssertFalse(registeredTag!.notes.contains(where: {
            n in n.isEqual(note)
        }))
        XCTAssertFalse(registeredNote!.tags.contains(where: {
            t in t.isEqual(tag)
        }))
    }

    func testDeleteFromNoteWithoutSavedNote() {
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag)
        }

        XCTAssertThrowsError(try Tag.delete(tag.id, from: note.id)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testDeleteFromNoteWithoutSavetTag() {
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            realm.add(note)
        }

        XCTAssertThrowsError(try Tag.delete(tag.id, from: note.id)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testDeleteFromNoteWhichHasNoSpecifiedTag() {
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag)
            realm.add(note)
        }

        XCTAssertNoThrow(try Tag.delete(tag.id, from: note.id))
    }
}
