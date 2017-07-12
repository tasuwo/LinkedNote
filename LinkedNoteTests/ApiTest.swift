//
//  ApiTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class ApiTest: XCTestCase {

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - .all()

    func testThatItReturn0WhenTryToGetAllObjectsIfThereAreNoObjects() {
        // given
        // No objects added to database

        // then       when
        XCTAssertTrue(Api.all().count == 0)
    }

    func testThatItGetAllObjects() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test1"))
            realm.add(Api(signature: "test2"))
            realm.add(Api(signature: "test3"))
        }

        // when
        let all = Api.all()

        // then
        XCTAssertTrue(all.count == 3)
        XCTAssertTrue(all.contains(where: { api in api.signature == "test1" }))
        XCTAssertTrue(all.contains(where: { api in api.signature == "test2" }))
        XCTAssertTrue(all.contains(where: { api in api.signature == "test3" }))
    }

    // MARK: - .get(_)

    func testThatItReturnNilWhenTryToGetObjectBySignatureIfThereAreNoTargetObject() {
        // given
        // No objects added to database

        // then      when
        XCTAssertNil(Api.get(signature: "test"))
    }

    func testThatItGetAnObjectBySignature() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
            realm.add(Api(signature: "testFake"))
        }

        // when
        let api = Api.get(signature: "test")

        // then
        XCTAssertTrue(api?.signature == "test")
    }

    // MARK: - .add(_)

    func testThatItAddObject() {
        // given
        let api = Api(signature: "test")

        // when
        try! Api.add(api)

        // then
        let realm = try! Realm()
        let results = realm.objects(Api.self).filter("signature == 'test'")
        XCTAssertTrue(results.count == 1)
        XCTAssertTrue(results.first?.signature == "test")
    }

    func testThatItThrowErrorIfTryToAddObjectWithDupricatedSignature() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
        }
        let api = Api(signature: "test")

        // when
        XCTAssertThrowsError(try Api.add(api)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }

    func testThatItThrowErrorIfTryToAddObjectWithDupricatedId() {
        // given
        let api1 = Api(signature: "test1")
        let api2 = Api(signature: "test2")
        let realm = try! Realm()
        try! realm.write {
            realm.add(api1)
        }

        // when
        XCTAssertThrowsError(try Api.add(api2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    // MARK: - .delete(_)

    func testThatItDeleteObject() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
        }

        // when
        Api.delete(signature: "test")

        // then
        let results = realm.objects(Api.self).filter("signature == 'test'")
        XCTAssertTrue(results.count == 0)
    }

    func testThatItThrowNoExceptionIfTryToDeleteNotExistObject() {
        // given
        // No object added to database

        // then          when
        XCTAssertNoThrow(Api.delete(signature: "test"))
    }
}
