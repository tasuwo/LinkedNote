//
//  Api.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import Realm
import RealmSwift

class Api: Object {
    private(set) dynamic var id = 0
    private(set) dynamic var signature = ""
    let accounts = List<ApiAccount>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func lastId() -> Int {
        let realm = try! Realm()
        return realm.objects(Api.self).last?.id ?? -1
    }
    
    convenience init (signature: String) {
        self.init()
        self.id = Api.lastId() + 1
        self.signature = signature
    }
}

// MARK: - Entity model methods

extension Api {
    static func all() -> Results<Api> {
        let realm = try! Realm()
        return realm.objects(Api.self)
    }
    
    static func get(signature: String) -> Api? {
        let realm = try! Realm()
        return realm.objects(Api.self).filter("signature == '\(signature)'").first
    }
    
    static func add(_ api: Api) {
        let realm = try! Realm()
        try! realm.write {
            if realm.object(ofType: Api.self, forPrimaryKey: api.id) != nil {
                realm.create(Api.self, value: api, update: true)
            } else {
                realm.add(api)
            }
        }
    }
}
