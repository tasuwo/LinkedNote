//
//  APIWrapper.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

enum APIError: Error {
    // Login
    case NotLoggedIn

    // API side error
    case APIError(Error)
    case FailedToGetUserNameByAPI
    case ResponseIsNil
    case UnexpectedAPIResponseFormat

    // Client side error
    case UserNotFoundInDatabase
}

protocol APIWrapper {
    static var signature: String { get }
    static func getUsername() -> String?
    static func isLoggedIn() -> Bool
    static func login(completion: @escaping (_: APIError?) -> Void)
    static func logout()
    func setUnitNum(_ num: Int)
    func initOffset()
    func retrieve(_ completion: @escaping (([Article], APIError?) -> Void))
    func retrieveArchives(_ completion: @escaping (([Article], APIError?) -> Void))
    func archive(id: String, completion: @escaping ((APIError?) -> Void))
    func delete(id: String, completion: @escaping ((APIError?) -> Void))
}
