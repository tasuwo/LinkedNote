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

    func testAll() {
        XCTAssertTrue(Api.all().count == 0)

        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test1"))
            realm.add(Api(signature: "test2"))
            realm.add(Api(signature: "test3"))
        }

        let all = Api.all()
        XCTAssertTrue(all.count == 3)
        XCTAssertTrue(all.contains(where: { api in api.signature == "test1" }))
        XCTAssertTrue(all.contains(where: { api in api.signature == "test2" }))
        XCTAssertTrue(all.contains(where: { api in api.signature == "test3" }))
    }

    func testGet() {
        XCTAssertNil(Api.get(signature: "test"))

        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
            realm.add(Api(signature: "testFake"))
        }

        let api = Api.get(signature: "test")
        XCTAssertTrue(api?.signature == "test")
    }

    func testAdd() {
        let api = Api(signature: "test")
        try! Api.add(api)

        let realm = try! Realm()
        let results = realm.objects(Api.self).filter("signature == 'test'")
        XCTAssertTrue(results.count == 1)
        XCTAssertTrue(results.first?.signature == "test")
    }

    func testAddWithDupricatedSignature() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
        }

        let api = Api(signature: "test")
        XCTAssertThrowsError(try Api.add(api)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }

    func testAddWithDupricatedId() {
        let api1 = Api(signature: "test1")
        let api2 = Api(signature: "test2")
        let realm = try! Realm()
        try! realm.write {
            realm.add(api1)
        }

        XCTAssertThrowsError(try Api.add(api2)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    func testDelete() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
        }

        Api.delete(signature: "test")

        let realm2 = try! Realm()
        let results = realm2.objects(Api.self).filter("signature == 'test'")

        XCTAssertTrue(results.count == 0)
    }

    func testDeleteFakeApi() {
        XCTAssertNoThrow(Api.delete(signature: "test"))
    }
}
