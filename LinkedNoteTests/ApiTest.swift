//
//  apiRepositoryTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import XCTest

class ApiTest: XCTestCase {
    private let apiRepository: Repository<Api> = Repository<Api>()

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - .findBy(signature)

    func testThatItGetAnObjectBySignature() {
        // given
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
            realm.add(Api(signature: "testFake"))
        }

        // when
        let api = apiRepository.findBy(signature: "test")

        // then
        XCTAssertTrue(api?.signature == "test")
    }

    // MARK: - .add(_)

    func testThatItAddObject() {
        // given
        let api = Api(signature: "test")

        // when
        try! apiRepository.add(api)

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
        XCTAssertThrowsError(try apiRepository.add(api)) { error in
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
        XCTAssertThrowsError(try apiRepository.add(api2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }
}
