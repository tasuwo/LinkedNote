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

    // MARK: - .getAll()

    func testThatItReturnEmptyResultIfThereAreNoSavedNotes() {
        // given
        // No objects saved

        // then       when
        XCTAssertTrue(Tag.getAll().count == 0)
    }

    func testThatItGetAllSavedNotes() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(Tag(name: "test_tag1"))
            realm.add(Tag(name: "test_tag2"))
        }

        // when
        let tags = Tag.getAll()

        // then
        XCTAssertTrue(tags.count == 2)
        XCTAssertTrue(tags.contains(where: { t in t.name == "test_tag1" }))
        XCTAssertTrue(tags.contains(where: { t in t.name == "test_tag2" }))
    }

    // MARK: - .get(_)

    func testThatItReturnNilWhenTryToGetTagByIdIfThereAreNoSavedTargetTag() {
        // given
        // No objects saved

        // then      when
        XCTAssertNil(Tag.get(0))
    }

    func testThatItGetTagById() throws {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(Tag(name: "test_tag1"))
        }

        // when
        let tag = try AssertNotNilAndUnwrap(Tag.get(0))

        // then
        XCTAssertTrue(tag.name == "test_tag1")
    }

    // MARK: - .get(noteId:_)

    func testThatItReturnEmptyResultWhenTryToGetTagByNoteIdIfThereAreNoSavedTargetTag() {
        // given
        // No objects saved

        // then       when
        XCTAssertTrue(Tag.get(noteId: 0).count == 0)
    }

    func testThatItGetNoteByNoteId() {
        // given
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

        // when
        let result = Tag.get(noteId: 0)

        // then
        XCTAssertTrue(result.count == 2)
        XCTAssertTrue(result.contains(where: { t in t.name == "test_tag1" }))
        XCTAssertTrue(result.contains(where: { t in t.name == "test_tag2" }))
    }

    // MARK: - .add(_)

    func testThatItAddTag() throws {
        // given
        let tag = Tag(name: "test_tag")

        // when
        try! Tag.add(tag)

        // then
        let realm = try! Realm()
        let result = try AssertNotNilAndUnwrap(realm.object(ofType: Tag.self, forPrimaryKey: 0))
        XCTAssertTrue(result.name == "test_tag")
    }

    func testThatItThrowErrorIfTryToAddTagWithDupricatedId() {
        // given
        let tag1 = Tag(name: "test_tag1")
        let tag2 = Tag(name: "test_tag2")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag1)
        }

        // when
        XCTAssertThrowsError(try Tag.add(tag2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    // MARK: - .add(_, to:_)

    func testThatItRelateTagToNote() throws {
        let note = Note(body: "test_note")
        let tag = Tag(name: "test_tag")

        let realm = try! Realm()
        try! realm.write {
            realm.add(note)
            realm.add(tag)
        }

        try! Tag.add(tag, to: note)

        let registeredNote = try AssertNotNilAndUnwrap(realm.object(ofType: Note.self, forPrimaryKey: 0))
        let registeredTag = try AssertNotNilAndUnwrap(realm.object(ofType: Tag.self, forPrimaryKey: 0))
        XCTAssertTrue(registeredNote.body == "test_note")
        XCTAssertTrue(registeredTag.name == "test_tag")
        // check relation
        XCTAssertTrue(registeredNote.tags.contains(where: {
            t in t.isEqual(registeredTag)
        }))
        XCTAssertTrue(registeredTag.notes.contains(where: {
            n in n.isEqual(registeredNote)
        }))
    }

    func testThatItThrowErrorIfTryToRelateNotSavedTagToNote() {
        // given
        let note = Note(body: "test_note")
        let tag = Tag(name: "test_tag")

        let realm = try! Realm()
        try! realm.write {
            realm.add(note)
        }

        // when
        XCTAssertThrowsError(try Tag.add(tag, to: note)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThaItThrowErrorIfTryToRelateTagToNotSavedNote() {
        // given
        let note = Note(body: "test_note")
        let tag = Tag(name: "test_tag")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag)
        }

        // when
        XCTAssertThrowsError(try Tag.add(tag, to: note)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    // MARK: - .delete()

    func testThatItDoesNotThrowErrorWhenTryToDeleteNotExistTag() {
        // given
        let tag = Tag(name: "test_tag")

        // then          when
        XCTAssertNoThrow(Tag.delete(tag))
    }

    func testThatItDeleteTagByDataModelObject() {
        // given
        let tag = Tag(name: "test_tag")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag)
        }
        // check the tag saved correctly
        XCTAssertNotNil(realm.object(ofType: Tag.self, forPrimaryKey: 0))

        // when
        Tag.delete(tag)

        // then
        XCTAssertNil(realm.object(ofType: Tag.self, forPrimaryKey: 0))
    }

    // MARK: - .delete(_, from:_)

    func testThatItDeleteRelationOfTagAndNote() throws {
        // given
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            note.tags.append(tag)
            realm.add(tag)
            realm.add(note)
        }
        // check objects saved correctly
        var registeredTag = try AssertNotNilAndUnwrap(realm.object(ofType: Tag.self, forPrimaryKey: 0))
        var registeredNote = try AssertNotNilAndUnwrap(realm.object(ofType: Note.self, forPrimaryKey: 0))
        XCTAssertTrue(registeredTag.notes.contains(where: {
            n in n.isEqual(note)
        }))
        XCTAssertTrue(registeredNote.tags.contains(where: {
            t in t.isEqual(tag)
        }))

        // when
        try! Tag.delete(tag.id, from: note.id)

        // then
        registeredTag = try AssertNotNilAndUnwrap(realm.object(ofType: Tag.self, forPrimaryKey: 0))
        registeredNote = try AssertNotNilAndUnwrap(realm.object(ofType: Note.self, forPrimaryKey: 0))
        XCTAssertFalse(registeredTag.notes.contains(where: {
            n in n.isEqual(note)
        }))
        XCTAssertFalse(registeredNote.tags.contains(where: {
            t in t.isEqual(tag)
        }))
    }

    func testThatItThrowErrorWhenDeleteRelationOfTagAndNotSavedNote() {
        // given
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            note.tags.append(tag)
            realm.add(tag)
        }

        // when
        XCTAssertThrowsError(try Tag.delete(tag.id, from: note.id)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItThrowErrorWhenDeleteRelationOfNotSavedTagAndNote() {
        // given
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            // If append tag to note here, tag will saved with note
            // So don't relate tag to note
            realm.add(note)
        }

        // when
        XCTAssertThrowsError(try Tag.delete(tag.id, from: note.id)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItDoesNotThrowErrorWhenDeleteNotExistRelationOfTagAndNote() {
        // given
        let tag = Tag(name: "test_tag")
        let note = Note(body: "test_note")

        let realm = try! Realm()
        try! realm.write {
            realm.add(tag)
            realm.add(note)
        }

        // then          when
        XCTAssertNoThrow(try Tag.delete(tag.id, from: note.id))
    }
}
