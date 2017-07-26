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

    convenience init(signature: String) {
        self.init()
        self.id = Api.lastId() + 1
        self.signature = signature
    }
}

// MARK: - Entity model methods

extension RepositoryProtocol where Self: Repository<Api> {
    func findBy(signature: String) -> Api? {
        return find(predicate: NSPredicate(format: "ANY Api.signature == '%@'", [signature])).first
    }

    func add(_ api: Api) throws {
        let realm = try! Realm()
        try realm.write {
            if realm.objects(Api.self).filter("signature == '\(api.signature)'").count > 0 {
                throw DataModelError.IntegrityConstraintViolation
            }
            if let _ = realm.object(ofType: Api.self, forPrimaryKey: api.id) {
                throw DataModelError.PrimaryKeyViolation
            }
            realm.add(api)
        }
    }
}
