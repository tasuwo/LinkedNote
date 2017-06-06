//
//  APIWrapper.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

protocol APIWrapper {
    static var signature: String { get }
    static func getUsername() -> String?
    static func isLoggedIn() -> Bool
    static func login(completion: @escaping (_: Error?) -> Void)
    static func logout()
    func setUnitNum(_ num: Int)
    func initOffset()
    func retrieve(_ completion: @escaping (([Article]) -> Void))
    func archive(id: String, completion: @escaping ((Bool) -> Void))
}
