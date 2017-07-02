//
//  FakeAPIWrappers.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
@testable import LinkedNote

class FakeAPIWrapper: APIWrapper {
    static var signature: String = "fake"
    static var loggedIn = false
    static var willOccurLoginError = false
    static var willLoginWithoutUsername = false
    static var username: String?

    static func initialize() {
        signature = "fake"
        loggedIn = false
        willOccurLoginError = false
        willLoginWithoutUsername = false
        username = nil
    }

    static func getUsername() -> String? {
        return username
    }

    static func isLoggedIn() -> Bool {
        return loggedIn
    }

    static func login(completion: @escaping (Error?) -> Void) {
        if willOccurLoginError {
            let error = NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "test"])
            completion(error)
        }
        if !willLoginWithoutUsername {
            username = "testUsername"
        }
        loggedIn = true
        completion(nil)
    }

    static func logout() {
        loggedIn = false
    }

    func setUnitNum(_: Int) {}
    func initOffset() {}
    func retrieve(_: @escaping (([Article]) -> Void)) {}
    func archive(id _: String, completion _: @escaping ((Bool) -> Void)) {}
}
