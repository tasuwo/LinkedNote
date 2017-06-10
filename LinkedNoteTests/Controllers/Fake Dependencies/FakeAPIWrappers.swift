//
//  FakeAPIWrappers.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
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

class LoginFailFakeAPIWrapper: APIWrapper {
    static var signature: String = "fake"
    static func getUsername() -> String? { return nil }
    static func isLoggedIn() -> Bool { return false }
    static func login(completion: @escaping (Error?) -> Void) {
        completion(Error())
    }
    static func logout() {}
    func setUnitNum(_ num: Int) {}
    func initOffset() {}
    func retrieve(_ completion: @escaping (([Article]) -> Void)) {}
    func archive(id: String, completion: @escaping ((Bool) -> Void)) {}
}
