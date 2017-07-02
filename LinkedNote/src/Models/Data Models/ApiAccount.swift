//
//  ApiAccount.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import Realm
import RealmSwift

// TODO: ユーザ名が変更された場合にどうするか
class ApiAccount: Object {
    dynamic var id = 0
    dynamic var username = ""
    let api = LinkingObjects(fromType: Api.self, property: "accounts")
    let articles = List<Article>()

    override static func primaryKey() -> String? {
        return "id"
    }

    static func lastId() -> Int {
        let realm = try! Realm()
        return realm.objects(ApiAccount.self).last?.id ?? -1
    }

    convenience init(username: String) {
        self.init()
        self.id = ApiAccount.lastId() + 1
        self.username = username
    }
}

// MARK: - Entity model methods

extension ApiAccount {
    static func get(_ id: Int) -> ApiAccount? {
        let realm = try! Realm()
        return realm.object(ofType: ApiAccount.self, forPrimaryKey: id)
    }

    static func get(apiSignature: String, username: String) -> ApiAccount? {
        let realm = try! Realm()
        return realm.objects(ApiAccount.self).filter("ANY api.signature == '\(apiSignature)' AND username == '\(username)'").first
    }

    static func add(_ account: ApiAccount) throws {
        let realm = try! Realm()
        try realm.write {
            if let _ = realm.object(ofType: ApiAccount.self, forPrimaryKey: account.id) {
                throw DataModelError.PrimaryKeyViolation
            }
            realm.add(account)
        }
    }

    static func add(_ account: ApiAccount, to api: Api) throws {
        let realm = try! Realm()
        try realm.write {
            if let a = realm.object(ofType: ApiAccount.self, forPrimaryKey: account.id) {
                if !a.isEqual(account) {
                    throw DataModelError.InvalidParameter("保存されていない更新が含まれたアカウントオブジェクトです。更新を保存後に本操作を行ってください。")
                }
            } else {
                throw DataModelError.NecessaryDataDoesNotExist("アカウントが存在しません")
            }
            if realm.object(ofType: Api.self, forPrimaryKey: api.id) == nil {
                throw DataModelError.NecessaryDataDoesNotExist("APIが存在しません")
            }
            if let _ = realm.objects(ApiAccount.self).filter("ANY api.signature == '\(api.signature)' AND username == '\(account.username)'").first {
                throw DataModelError.IntegrityConstraintViolation
            }
            api.accounts.append(account)
            realm.add(api, update: true)
        }
    }
}
