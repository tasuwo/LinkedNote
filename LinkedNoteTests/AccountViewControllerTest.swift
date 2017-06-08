//
//  AccountViewControllerTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
@testable import LinkedNote

class LoggedInFakeAPIWrapper: APIWrapper {
    static var signature: String = "fake"
    static func getUsername() -> String? { return nil }
    static func isLoggedIn() -> Bool { return true }
    static func login(completion: @escaping (Error?) -> Void) {}
    static func logout() {}
    func setUnitNum(_ num: Int) {}
    func initOffset() {}
    func retrieve(_ completion: @escaping (([Article]) -> Void)) {}
    func archive(id: String, completion: @escaping ((Bool) -> Void)) {}
}

class LoggedOutFakeAPIWrapper: APIWrapper {
    static var signature: String = "fake"
    static func getUsername() -> String? { return nil }
    static func isLoggedIn() -> Bool { return false }
    static func login(completion: @escaping (Error?) -> Void) {}
    static func logout() {}
    func setUnitNum(_ num: Int) {}
    func initOffset() {}
    func retrieve(_ completion: @escaping (([Article]) -> Void)) {}
    func archive(id: String, completion: @escaping ((Bool) -> Void)) {}
}

class FakeViewCalculator: FrameCalculator {
    func calcFrameOnTabAndNavBar(by: UIViewController) -> CGRect {
        return by.view.frame
    }
    func calcFrameOnNavVar(by: UIViewController) -> CGRect {
        return by.view.frame
    }
}

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
        let vc = AccountViewController(api: LoggedInFakeAPIWrapper(), calculator: FakeViewCalculator())
        // Call view to execute viewDidLoad
        _ = vc.view
        XCTAssert(vc.currentActiveView as? AccountView != nil, "ログアウトしている場合は、アカウント画面を表示する")
    }
    
    func testDisplayLoginViewWhenUserLoggedOut() {
        let vc = AccountViewController(api: LoggedOutFakeAPIWrapper(), calculator: FakeViewCalculator())
        // Call view to execute viewDidLoad
        _ = vc.view
        XCTAssert(vc.currentActiveView as? SignInView != nil, "ログインしている場合は、ログアウト用画面を表示する")
    }
}
