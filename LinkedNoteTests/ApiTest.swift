//
//  apiRepositoryTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class ApiTest: XCTestCase {
    private let apiRepository: Repository<Api> = Repository<Api>()

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
        XCTAssertTrue(apiRepository.all().count == 0)
    }

    func testThatItGetAllObjects() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(apiRepository(signature: "test1"))
            realm.add(apiRepository(signature: "test2"))
            realm.add(apiRepository(signature: "test3"))
        }

        // when
        let all = apiRepository.all()

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
        XCTAssertNil(apiRepository.get(signature: "test"))
    }

    func testThatItGetAnObjectBySignature() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(apiRepository(signature: "test"))
            realm.add(apiRepository(signature: "testFake"))
        }

        // when
        let api = apiRepository.get(signature: "test")

        // then
        XCTAssertTrue(api?.signature == "test")
    }

    // MARK: - .add(_)

    func testThatItAddObject() {
        // given
        let api = apiRepository(signature: "test")

        // when
        try! apiRepository.add(api)

        // then
        let realm = try! Realm()
        let results = realm.objects(apiRepository.self).filter("signature == 'test'")
        XCTAssertTrue(results.count == 1)
        XCTAssertTrue(results.first?.signature == "test")
    }

    func testThatItThrowErrorIfTryToAddObjectWithDupricatedSignature() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(apiRepository(signature: "test"))
        }
        let api = apiRepository(signature: "test")

        // when
        XCTAssertThrowsError(try apiRepository.add(api)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }

    func testThatItThrowErrorIfTryToAddObjectWithDupricatedId() {
        // given
        let api1 = apiRepository(signature: "test1")
        let api2 = apiRepository(signature: "test2")
        let realm = try! Realm()
        try! realm.write {
            realm.add(api1)
        }

        // when
        XCTAssertThrowsError(try apiRepository.add(api2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    // MARK: - .delete(_)

    func testThatItDeleteObject() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(apiRepository(signature: "test"))
        }

        // when
        apiRepository.delete(signature: "test")

        // then
        let results = realm.objects(apiRepository.self).filter("signature == 'test'")
        XCTAssertTrue(results.count == 0)
    }

    func testThatItThrowNoExceptionIfTryToDeleteNotExistObject() {
        // given
        // No object added to database

        // then          when
        XCTAssertNoThrow(apiRepository.delete(signature: "test"))
    }
}
