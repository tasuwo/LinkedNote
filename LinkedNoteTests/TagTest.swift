//
//  TagTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/05.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class TagTest: XCTestCase {
    private let repo: Repository<Tag> = Repository<Tag>()

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - .findBy(noteId:_)

    func testThatItReturnEmptyResultWhenTryToGetTagByNoteIdIfThereAreNoSavedTargetTag() {
        // given
        // No objects saved

        // then       when
        XCTAssertTrue(repo.findBy(noteId: 0).count == 0)
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
        let result = repo.findBy(noteId: 0)

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
        try! repo.add(tag)

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
        XCTAssertThrowsError(try repo.add(tag2)) { error in
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

        try! repo.add(tag, to: note)

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
        XCTAssertThrowsError(try repo.add(tag, to: note)) { error in
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
        XCTAssertThrowsError(try repo.add(tag, to: note)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
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
        try! repo.delete(tag.id, from: note.id)

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
        XCTAssertThrowsError(try repo.delete(tag.id, from: note.id)) { error in
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
        XCTAssertThrowsError(try repo.delete(tag.id, from: note.id)) { error in
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
        XCTAssertNoThrow(try repo.delete(tag.id, from: note.id))
    }
}
