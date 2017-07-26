//
//  ApiAccountTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class ApiAccountTest: XCTestCase {
    private let repo = Repository<ApiAccount>()

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - .findBy(apiSignature,username)

    func testThatItReturnNilWhenTryToGetObjectBySignatureAndUsername() {
        // given
        // No objects added to database

        // then
        XCTAssertNil(repo.find(apiSignature: "test", username: "test_username"))
    }

    func testThatItGetObjectBySignatureAndUsername() {
        // given
        let realm = try! Realm()
        try! realm.write {
            let account = ApiAccount(username: "test_username")
            realm.add(account)
            let registeredAccount = realm.object(ofType: ApiAccount.self, forPrimaryKey: 0)!

            let api = Api(signature: "test")
            api.accounts.append(registeredAccount)
            realm.add(api)
        }

        // when
        let account = repo.find(apiSignature: "test", username: "test_username")

        // then
        XCTAssertTrue(account?.username == "test_username")
    }

    // MARK: - .add(_)

    func testThatItAddObject() {
        // given
        let account = ApiAccount(username: "test_username")

        // when
        try! repo.add(account)

        // then
        let realm = try! Realm()
        let results = realm.objects(ApiAccount.self).filter("username == 'test_username'")
        XCTAssertTrue(results.count == 1)
        XCTAssertTrue(results.first?.username == "test_username")
    }

    func testThatItThrowErrorIfTryToAddObjectWithDupricatedId() {
        // given
        let account1 = ApiAccount(username: "test1_username")
        let account2 = ApiAccount(username: "test2_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(account1)
        }

        // when
        XCTAssertThrowsError(try repo.add(account2)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }

    // MARK: - .add(_, to:_)

    func testThatItRelateObjectToApi() throws {
        // given
        let account = ApiAccount(username: "test_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
            realm.add(account)
        }

        // when
        // TODO: Api に依存させない
        try! repo.add(account, to: Repository<Api>().findBy(signature: "test")!)

        // then
        let registeredApi = try AssertNotNilAndUnwrap(realm.object(ofType: Api.self, forPrimaryKey: 0))
        let registeredAccount = try AssertNotNilAndUnwrap(realm.object(ofType: ApiAccount.self, forPrimaryKey: 0))
        let apiRelatedToRegisteredAccount = try AssertNotNilAndUnwrap(registeredAccount.api.first)
        let accountRelatedToRegisteredApi = try AssertNotNilAndUnwrap(registeredApi.accounts.first)
        XCTAssertTrue(registeredAccount.username == "test_username")
        XCTAssertTrue(registeredApi.signature == "test")
        XCTAssertTrue(apiRelatedToRegisteredAccount.id == registeredApi.id)
        XCTAssertTrue(apiRelatedToRegisteredAccount.signature == registeredApi.signature)
        XCTAssertTrue(accountRelatedToRegisteredApi.id == registeredAccount.id)
        XCTAssertTrue(accountRelatedToRegisteredApi.username == registeredAccount.username)
    }

    func testThatItThrowErrorWhenTryToAddNotSavedObjectToApi() {
        // given
        let api = Api(signature: "test")
        let account = ApiAccount(username: "test_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(api)
        }

        // when
        XCTAssertThrowsError(try repo.add(account, to: api)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItThrowErrorWhenTryToAddObjectToNotSavedApi() {
        // given
        let api = Api(signature: "test")
        let account = ApiAccount(username: "test_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(account)
        }

        // when
        XCTAssertThrowsError(try repo.add(account, to: api)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }

    func testThatItThrowErrorWhenTryToRelateObjectsWhichHasSameUsernameToSameApi() {
        // given
        let api = Api(signature: "test")
        let realm = try! Realm()
        try! realm.write {
            let account = ApiAccount(username: "test_username")
            api.accounts.append(account)
            realm.add(account)
            realm.add(api)
        }
        let dupricatedAccount = ApiAccount(username: "test_username")
        try! realm.write {
            realm.add(dupricatedAccount)
        }

        // when
        XCTAssertThrowsError(try repo.add(dupricatedAccount, to: api)) { error in
            // then
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }

    func testThatItThrowErrorWhenTryToRelateObjects_WhichHasSameIdButDifferentParamsFromSavedOne_toApi() throws {
        let account = ApiAccount(username: "test_username")
        let dupAccount = ApiAccount(username: "duplicated_account_username")
        let api = Api(signature: "test")
        let realm = try! Realm()
        try! realm.write {
            realm.add(api)
            realm.add(account)
        }

        XCTAssertThrowsError(try repo.add(dupAccount, to: api)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.InvalidParameter(""))
        }
    }
}
