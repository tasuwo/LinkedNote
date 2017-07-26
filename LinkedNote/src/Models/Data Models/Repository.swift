//
//  Repository.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/24.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import RealmSwift

protocol RepositoryProtocol {
    associatedtype DomainType: Object
    func find(primaryKey: Int) -> DomainType?
    func findAll() -> Results<DomainType>
    func find(predicate: NSPredicate) -> Results<DomainType>
    func delete(_ domains: [DomainType])
}

class Repository<DomainType: Object>: RepositoryProtocol {
    func find(primaryKey: Int) -> DomainType? {
        let realm = try! Realm()
        return realm.object(ofType: DomainType.self, forPrimaryKey: primaryKey)
    }

    func findAll() -> Results<DomainType> {
        let realm = try! Realm()
        return realm.objects(DomainType.self)
    }

    func find(predicate: NSPredicate) -> Results<DomainType> {
        let realm = try! Realm()
        return realm.objects(DomainType.self).filter(predicate)
    }

    func delete(_ domains: [DomainType]) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(domains)
        }
    }
}
