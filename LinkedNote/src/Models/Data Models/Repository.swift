//
//  Repository.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2017/07/24.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import RealmSwift

protocol RepositoryProtocol {
    associatedtype DomainType
    func find(primaryKey: String) -> DomainType?
}

class Repository<DomainType: Object> {
    
    var realm: Realm
    
    init() {
        self.realm = try! Realm()
    }
    
    func find(primaryKey: String) -> DomainType? {
        return realm.objects(DomainType.self).filter("id == %@", primaryKey).first
    }
    
    func findAll() -> [DomainType] {
        return realm.objects(DomainType.self).map({$0})
    }
    
    func find(predicate: NSPredicate) -> Results<DomainType> {
        return realm.objects(DomainType.self).filter(predicate)
    }
    
    func add(domains: [DomainType]) {
        try! realm.write {
            realm.add(domains, update: true)
        }
    }
    
    func delete(domains: [DomainType]) {
        try! realm.write {
            realm.delete(domains)
        }
    }
    
    func transaction(_ transactionBlock: () -> Void) {
        try! realm.write {
            transactionBlock()
        }
    }
    
    func resolve<Confined: ThreadConfined>(_ reference: ThreadSafeReference<Confined>) -> Confined? {
        return self.realm.resolve(reference)
    }
}
