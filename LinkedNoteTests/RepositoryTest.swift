//
//  RepositoryTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/26.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import UIKit
@testable import LinkedNote

import RealmSwift

class FakeObject: Object {
    private(set) dynamic var id = 0
    private(set) dynamic var message = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    static func lastId() -> Int {
        let realm = try! Realm()
        return realm.objects(FakeObject.self).last?.id ?? -1
    }

    convenience init(message: String) {
        self.init()
        self.id = FakeObject.lastId() + 1
        self.message = message
    }
}

class RepositoryTest: XCTestCase {
    private let repo = Repository<FakeObject>()

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - .find(primaryKey:String)

    func testThatItGetAnObjectByPrimaryKey() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(FakeObject(message: "test"))
        }

        // when
        let obj = repo.find(primaryKey: 0)

        // then
        XCTAssertTrue(obj?.message == "test")
    }

    func testThatItReturnNilWhenTryToGetObjectByPrimaryKeyIfThereAreNoTargetObject() {
        // given
        // No objects added to database

        // then      when
        XCTAssertNil(repo.find(primaryKey: 0))
    }

    // MARK: - .findAll()

    func testThatItReturn0WhenTryToGetAllObjectsIfThereAreNoObjects() {
        // given
        // No objects added to database

        // then       when
        XCTAssertTrue(repo.findAll().count == 0)
    }

    func testThatItGetAllObjects() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(FakeObject(message: "test1"))
            realm.add(FakeObject(message: "test2"))
            realm.add(FakeObject(message: "test3"))
        }

        // when
        let all = repo.findAll()

        // then
        XCTAssertTrue(all.count == 3)
        XCTAssertTrue(all.contains(where: { obj in obj.message == "test1" }))
        XCTAssertTrue(all.contains(where: { obj in obj.message == "test2" }))
        XCTAssertTrue(all.contains(where: { obj in obj.message == "test3" }))
    }

    // MARK: - find(predicate:NSPredicate)

    // MARK: - delete(_:[DomainType])

    func testThatItDeleteObject() {
        // given
        let obj = FakeObject(message: "test")
        let realm = try! Realm()
        try! realm.write {
            realm.add(obj)
        }

        // when
        repo.delete([obj])

        // then
        let results = realm.objects(FakeObject.self)
        XCTAssertTrue(results.count == 0)
    }

    func testThatItThrowNoExceptionIfTryToDeleteNotExistObject() {
        // given
        let obj = FakeObject(message: "test")

        // then
        XCTAssertNoThrow(repo.delete([obj]))
    }
}
