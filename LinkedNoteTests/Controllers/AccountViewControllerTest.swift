//
//  AccountViewControllerTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
@testable import LinkedNote

class AccountViewControllerTest: XCTestCase {
    var viewController: AccountViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDisplayLogoutViewWhenUserLoggedIn() {
        let vc = AccountViewController(api: LoggedInFakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view
        XCTAssert(vc.currentActiveView as? AccountView != nil, "ログアウトしている場合は、アカウント画面を表示する")
    }
    
    func testDisplayLoginViewWhenUserLoggedOut() {
        let vc = AccountViewController(api: LoggedOutFakeAPIWrapper(), calculator: FakeViewCalculator(), alertPresenter: FakeAlertPresenter())
        // Call view to execute viewDidLoad
        _ = vc.view
        XCTAssert(vc.currentActiveView as? SignInView != nil, "ログインしている場合は、ログアウト用画面を表示する")
    }
}
