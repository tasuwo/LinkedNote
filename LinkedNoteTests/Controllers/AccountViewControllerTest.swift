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

    func testThatItShowViewForLogoutIfUserLoggedInAlready() {
        FakeAPIWrapper.loggedIn = true

        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view

        XCTAssertNotNil(vc.view.subviews.last as? AccountView)
        XCTAssertNotNil(vc.currentActiveView as? AccountView)
    }

    func testThatItShowViewForLogInIfUserLoggedOutAlready() {
        FakeAPIWrapper.loggedIn = false

        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view

        XCTAssertNotNil(vc.view.subviews.last as? SignInView)
        XCTAssertNotNil(vc.currentActiveView as? SignInView)
    }

    func testThatItShowAlertIfUnexpectedErrorOccuredDuringLoggingIn() {
        FakeAPIWrapper.loggedIn = false
        FakeAPIWrapper.willOccurLoginError = true

        let ap = FakeAlertPresenter()
        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: ap)
        // Call view to execute viewDidLoad
        _ = vc.view

        vc.didTouchLoginButton()

        XCTAssertTrue(ap.lastErrorMessage == "test")
    }

    func testThatItColudLogInAndSaveNewApiAccountIfTheUserLoggedInForTheFirstTime() {
        FakeAPIWrapper.loggedIn = false

        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view

        vc.didTouchLoginButton()

        XCTAssertTrue(FakeAPIWrapper.loggedIn)
        XCTAssertNotNil(ApiAccount.get(apiSignature: FakeAPIWrapper.signature, username: FakeAPIWrapper.getUsername()!))
        XCTAssertNotNil(vc.currentActiveView as? AccountView)
    }

    func testThatItColudLogInIfTheUsersAccountWasSavedAlready() {
        FakeAPIWrapper.loggedIn = false
        //
        let account = ApiAccount(username: "test_username")
        try! ApiAccount.add(account)
        try! ApiAccount.add(account, to: Api.get(signature: FakeAPIWrapper.signature)!)

        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view

        vc.didTouchLoginButton()

        XCTAssertTrue(FakeAPIWrapper.loggedIn)
        XCTAssertNotNil(ApiAccount.get(apiSignature: FakeAPIWrapper.signature, username: FakeAPIWrapper.getUsername()!))
        XCTAssertNotNil(vc.currentActiveView as? AccountView)
    }

    func testThatItCouldLogOut() {
        FakeAPIWrapper.loggedIn = true

        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view

        vc.didTouchLogOutButton()

        XCTAssertFalse(FakeAPIWrapper.loggedIn)
        XCTAssertNotNil(vc.currentActiveView as? SignInView)
    }

    // negative testing

    func testThatItShowAlertIfTheApiColudntGetTheUsername() {
        FakeAPIWrapper.loggedIn = false

        // This is Api wrapper's error.
        FakeAPIWrapper.willLoginWithoutUsername = true
        let ap = FakeAlertPresenter()

        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: ap)
        // Call view to execute viewDidLoad
        _ = vc.view

        vc.didTouchLoginButton()

        XCTAssertTrue(ap.lastErrorMessage == "ユーザ名の取得に失敗しました")
        XCTAssertFalse(FakeAPIWrapper.loggedIn)
        XCTAssertNil(FakeAPIWrapper.getUsername())
        XCTAssertNil(vc.currentActiveView as? AccountView)
    }

    func testThatItShowAlertIfTheApiDataModelDidnotSavedYet() {
        FakeAPIWrapper.loggedIn = false
        let ap = FakeAlertPresenter()

        // Delete Api data model
        Api.delete(signature: FakeAPIWrapper.signature)

        let vc = AccountViewController(provider: AccountViewProviderImpl(), api: FakeAPIWrapper(), calculator: FakeFrameCalculator(), alertPresenter: ap)
        // Call view to execute viewDidLoad
        _ = vc.view

        vc.didTouchLoginButton()

        XCTAssertTrue(ap.lastErrorMessage == "登録されていない API です")
        XCTAssertFalse(FakeAPIWrapper.loggedIn)
        // TODO: ApiAccount に依存したテストになってしまっているので修正する
        XCTAssertNil(ApiAccount.get(apiSignature: FakeAPIWrapper.signature, username: FakeAPIWrapper.getUsername()!))
        XCTAssertNil(vc.currentActiveView as? AccountView)
    }

    // TODO: アカウントの登録に失敗した場合のエラー。データモデルをモックする必要がある
}
