//
//  FakeAPIWrappers.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import RealmSwift
import UIKit

class FakeAPIWrapper: APIWrapper {
    static var signature: String = "fake"
    static var loggedIn = false
    static var willOccurLoginError = false
    static var willLoginWithoutUsername = false
    static var username: String?
    static var willErrorAtRetrieve = false
    static var errorAtRetrieve: APIError?
    var unitNum: Int?
    var lastArchivedId: String?
    var offset: Int = 0
    var articles: [Article] = []

    static func initialize() {
        signature = "fake"
        loggedIn = false
        willOccurLoginError = false
        willLoginWithoutUsername = false
        username = nil
        willErrorAtRetrieve = false
    }

    static func getUsername() -> String? {
        return username
    }

    static func isLoggedIn() -> Bool {
        return loggedIn
    }

    static func login(completion: @escaping (APIError?) -> Void) {
        if willOccurLoginError {
            let error = NSError(domain: NSCocoaErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "test"])
            completion(error as? APIError)
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

    func setUnitNum(_ n: Int) {
        self.unitNum = n
    }

    func initOffset() {
        self.offset = 0
    }

    func retrieve(_ completion: @escaping (([Article], APIError?) -> Void)) {
        if FakeAPIWrapper.willErrorAtRetrieve {
            completion([], FakeAPIWrapper.errorAtRetrieve)
        } else {
            completion(articles, nil)
        }
    }

    func archive(id: String, completion: @escaping ((APIError?) -> Void)) {
        lastArchivedId = id
        completion(nil)
    }
}
