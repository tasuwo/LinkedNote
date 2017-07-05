//
//  FakeAPIWrappers.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import RealmSwift
@testable import LinkedNote

class FakeAPIWrapper: APIWrapper {
    static var signature: String = "fake"
    static var loggedIn = false
    static var willOccurLoginError = false
    static var willLoginWithoutUsername = false
    static var username: String?
    var unitNum: Int = -1
    var offset: Int = 0
    private let article1 = Article(localId: "0", title: "", url: "", thumbnailUrl: "")
    private let article2 = Article(localId: "1", title: "", url: "", thumbnailUrl: "")
    private let article3 = Article(localId: "2", title: "", url: "", thumbnailUrl: "")
    var articles = [ article1, article2, article3 ]

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

    func setUnitNum(_ n: Int) {
        self.unitNum = n
    }
    
    func initOffset() {
        self.offset = 0
    }
    
    func retrieve(_ completion: @escaping (([Article]) -> Void)) {
        completion(articles)
    }
    
    func archive(id _: String, completion _: @escaping ((Bool) -> Void)) {
    }
}
