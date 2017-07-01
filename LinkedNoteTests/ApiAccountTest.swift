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
    
    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetById() {
        XCTAssertNil(ApiAccount.get(0))
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(ApiAccount(username: "test_username"))
        }
        
        let account = ApiAccount.get(0)
        XCTAssertTrue(account?.username == "test_username")
    }
    
    func testGetBySignatureAndUsername() {
        XCTAssertNil(ApiAccount.get(apiSignature: "test", username: "test_username"))

        let realm = try! Realm()
        try! realm.write {
            let account = ApiAccount(username: "test_username")
            realm.add(account)
            let registeredAccount = realm.object(ofType: ApiAccount.self, forPrimaryKey: 0)!
            
            let api = Api(signature: "test")
            api.accounts.append(registeredAccount)
            realm.add(api)
        }

        let account = ApiAccount.get(apiSignature: "test", username: "test_username")
        XCTAssertTrue(account?.username == "test_username")
    }
    
    func testAdd() {
        let account = ApiAccount(username: "test_username")
        try! ApiAccount.add(account)
        
        let realm = try! Realm()
        let results = realm.objects(ApiAccount.self).filter("username == 'test_username'")
        XCTAssertTrue(results.count == 1)
        XCTAssertTrue(results.first?.username == "test_username")
    }
    
    func testAddWithDupricatedId() {
        let account1 = ApiAccount(username: "test1_username")
        let account2 = ApiAccount(username: "test2_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(account1)
        }
        
        XCTAssertThrowsError(try ApiAccount.add(account2)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.PrimaryKeyViolation)
        }
    }
    
    func testAddToApiAfterSaveAccount() {
        let account = ApiAccount(username: "test_username")
        let realm = try! Realm()
        try! realm.write {
            realm.add(Api(signature: "test"))
            realm.add(account)
        }
        try! ApiAccount.add(account, to: Api.get(signature: "test")!)
        
        let registeredApi = realm.object(ofType: Api.self, forPrimaryKey: 0)
        let registeredAccount = realm.object(ofType: ApiAccount.self, forPrimaryKey: 0)
        XCTAssertNotNil(registeredAccount)
        XCTAssertNotNil(registeredApi)
        XCTAssertTrue(registeredAccount!.username == "test_username")
        XCTAssertTrue(registeredApi!.signature == "test")
        XCTAssertTrue(registeredAccount!.api.first!.id == registeredApi!.id)
        XCTAssertTrue(registeredAccount!.api.first!.signature == registeredApi!.signature)
        XCTAssertTrue(registeredApi!.accounts.first!.id == registeredAccount!.id)
        XCTAssertTrue(registeredApi!.accounts.first!.username == registeredAccount!.username)
    }
    
    func testAddToApiBeforeSaveAccount() {
        let api = Api(signature: "test")
        let account = ApiAccount(username: "test_username")
        try! Api.add(api)
        
        XCTAssertThrowsError(try ApiAccount.add(account, to: api)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }
    
    func testAddToNotSavedApi() {
        let api = Api(signature: "test")
        let account = ApiAccount(username: "test_username")
        
        XCTAssertThrowsError(try ApiAccount.add(account, to: api)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.NecessaryDataDoesNotExist(""))
        }
    }
    
    func testAddToApiWithIntegrityConstraintViolation() {
        let api = Api(signature: "test")
    
        let realm = try! Realm()
        try! realm.write {
            let account = ApiAccount(username: "test_username")
            api.accounts.append(account)
            realm.add(account)
            realm.add(api)
            let account2 = ApiAccount(username: "test_username")
            realm.add(account2)
        }
        
        let account2 = realm.object(ofType: ApiAccount.self, forPrimaryKey: 1)!
        XCTAssertThrowsError(try ApiAccount.add(account2, to: api)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.IntegrityConstraintViolation)
        }
    }
    
    func testAddToApiWithoutUpdateAccount() {
        let account1 = ApiAccount(username: "test_username1")
        let account2 = ApiAccount(username: "test_username2")
        let api = Api(signature: "test")
        let realm = try! Realm()
        try! realm.write {
            realm.add(api)
            realm.add(account1)
        }
        
        XCTAssertThrowsError(try ApiAccount.add(account2, to: api)) { error in
            XCTAssertTrue(error as! DataModelError == DataModelError.InvalidParameter(""))
        }
    }
}
