//
//  AccountViewControllerTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class AccountViewControllerTest: XCTestCase {
    var viewController: AccountViewController!
    
    override func setUp() {
        super.setUp()
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let fakeApi = Api(signature: FakeAPIWrapper.signature)
        try! Api.add(fakeApi)
        
        FakeAPIWrapper.initialize()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // positive testing
    
    func testDisplayLogoutViewWhenUserLoggedIn() {
        FakeAPIWrapper.loggedIn = true
        
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view
        XCTAssertNotNil(vc.currentActiveView as? AccountView)
    }
    
    func testDisplayLoginViewWhenUserLoggedOut() {
        FakeAPIWrapper.loggedIn = false
        
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view
        XCTAssertNotNil(vc.currentActiveView as? SignInView)
    }
    
    func testAlertLoginError() {
        FakeAPIWrapper.loggedIn = false
        FakeAPIWrapper.willOccurLoginError = true
        
        let ap = FakeAlertPresenter()
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: ap)
        // Call view to execute viewDidLoad
        _ = vc.view
        
        vc.didTouchLoginButton()
        
        XCTAssertTrue(ap.lastErrorMessage == "test")
    }
    
    func testLoginWithoutAccountDataModel() {
        FakeAPIWrapper.loggedIn = false
        
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view
        
        vc.didTouchLoginButton()
        
        XCTAssertTrue(FakeAPIWrapper.loggedIn)
        XCTAssertNotNil(ApiAccount.get(apiSignature: FakeAPIWrapper.signature, username: FakeAPIWrapper.getUsername()!))
        XCTAssertNotNil(vc.currentActiveView as? AccountView)
    }
    
    func testLoginWithAccountDataModel() {
        FakeAPIWrapper.loggedIn = false
        //
        let account = ApiAccount(username: "test_username")
        try! ApiAccount.add(account)
        try! ApiAccount.add(account, to: Api.get(signature: FakeAPIWrapper.signature)!)
        
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view
        
        vc.didTouchLoginButton()
        
        XCTAssertTrue(FakeAPIWrapper.loggedIn)
        XCTAssertNotNil(ApiAccount.get(apiSignature: FakeAPIWrapper.signature, username: FakeAPIWrapper.getUsername()!))
        XCTAssertNotNil(vc.currentActiveView as? AccountView)
    }
    
    func testLogout() {
        FakeAPIWrapper.loggedIn = true
        
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view
        
        vc.didTouchLogOutButton()
        
        XCTAssertFalse(FakeAPIWrapper.loggedIn)
        XCTAssertNotNil(vc.currentActiveView as? SignInView)
    }
    
    // negative testing
    
    func testLoginWithoutUsernameSetting() {
        FakeAPIWrapper.loggedIn = false
        
        // This is Api wrapper's error.
        FakeAPIWrapper.willLoginWithoutUsername = true
        let ap = FakeAlertPresenter()
        
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: ap)
        // Call view to execute viewDidLoad
        _ = vc.view
        
        vc.didTouchLoginButton()
        
        XCTAssertTrue(ap.lastErrorMessage == "ユーザ名の取得に失敗しました")
        XCTAssertFalse(FakeAPIWrapper.loggedIn)
        XCTAssertNil(FakeAPIWrapper.getUsername())
        XCTAssertNil(vc.currentActiveView as? AccountView)
    }
    
    func testLoginWithoutApiDataModel() {
        FakeAPIWrapper.loggedIn = false
        let ap = FakeAlertPresenter()

        // Delete Api data model
        Api.delete(signature: FakeAPIWrapper.signature)
        
        let vc = AccountViewController(api: FakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: ap)
        // Call view to execute viewDidLoad
        _ = vc.view
        
        vc.didTouchLoginButton()
        
        XCTAssertTrue(ap.lastErrorMessage == "登録されていない API です")
        XCTAssertFalse(FakeAPIWrapper.loggedIn)
        XCTAssertNil(ApiAccount.get(apiSignature: FakeAPIWrapper.signature, username: FakeAPIWrapper.getUsername()!))
        XCTAssertNil(vc.currentActiveView as? AccountView)
    }
}
