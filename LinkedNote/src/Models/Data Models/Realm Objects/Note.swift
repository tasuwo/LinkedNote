//
//  Note.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import Realm
import RealmSwift

class Note: Object {
    dynamic var id = 0
    dynamic var body = ""
    private let articles = LinkingObjects(fromType: Article.self, property: "notes")
    var article: Article? {
        return self.articles.first
    }

    let tags = List<Tag>()

    override static func primaryKey() -> String? {
        return "id"
    }

    static func lastId() -> Int {
        let realm = try! Realm()
        return realm.objects(Note.self).max(ofProperty: "id") ?? -1
    }

    static func newId() -> Int {
        var newId = Note.lastId() + 1
        let realm = try! Realm()
        while let _ = realm.object(ofType: Note.self, forPrimaryKey: newId) {
            newId += 1
        }
        return newId
    }

    convenience init(body: String) {
        self.init()
        self.id = Note.newId()
        self.body = body
    }
}

// MARK: - Entity model methods

extension RepositoryProtocol where Self: Repository<Note> {
    func findBy(tagId: Int) -> Results<Note> {
        let realm = try! Realm()
        return realm.objects(Note.self).filter("ANY tags.id == \(tagId)")
    }

    func findBy(accountId: Int, articleLocalId: String) -> Note? {
        let accountRep: Repository<ApiAccount> = Repository<ApiAccount>()
        guard let account = accountRep.find(primaryKey: accountId) else {
            return nil
        }
        let article = account.articles.filter("localId == '\(articleLocalId)'").first
        return article?.note
    }

    func findBy(signature: String, username: String, article: Article) -> Note? {
        let accountRep: Repository<ApiAccount> = Repository<ApiAccount>()
        guard let account = accountRep.find(apiSignature: signature, username: username) else {
            return nil
        }

        let noteRep: Repository<Note> = Repository<Note>()
        guard let note = noteRep.findBy(accountId: account.id, articleLocalId: article.localId) else {
            return nil
        }
        return note
    }

    func add(_ note: Note) throws {
        let realm = try! Realm()
        try realm.write {
            if let _ = realm.object(ofType: Note.self, forPrimaryKey: note.id) {
                throw DataModelError.PrimaryKeyViolation
            }
            realm.add(note)
        }
    }

    func add(_ note: Note, to article: Article) throws {
        let realm = try! Realm()
        try realm.write {
            if let note_ = realm.object(ofType: Note.self, forPrimaryKey: note.id) {
                if note_.article != nil {
                    throw DataModelError.IntegrityConstraintViolation
                }
            } else {
                throw DataModelError.NecessaryDataDoesNotExist("ノートが存在しません")
            }
            if let article_ = realm.object(ofType: Article.self, forPrimaryKey: article.id) {
                if article_.note != nil {
                    throw DataModelError.IntegrityConstraintViolation
                }
            } else {
                throw DataModelError.NecessaryDataDoesNotExist("記事が存在しません")
            }
            article.notes.append(note)
            realm.add(article, update: true)
        }
    }

    func update(_ note: Note, body: String) {
        let realm = try! Realm()
        try! realm.write {
            note.body = body
            realm.add(note, update: true)
        }
    }
}
