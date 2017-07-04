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
        return realm.objects(Note.self).last?.id ?? -1
    }

    convenience init(body: String) {
        self.init()
        self.id = Note.lastId() + 1
        self.body = body
    }
}

// MARK: - Entity model methods

extension Note {
    static func getAll() -> Results<Note> {
        let realm = try! Realm()
        return realm.objects(Note.self)
    }

    static func get(_ id: Int) -> Note? {
        let realm = try! Realm()
        return realm.object(ofType: Note.self, forPrimaryKey: id)
    }

    static func get(signature: String, username: String, article: Article) -> Note? {
        if let account = ApiAccount.get(apiSignature: signature, username: username) {
            if let note = Note.get(accountId: account.id, articleLocalId: article.localId) {
                return note
            }
        }
        return nil
    }

    static func get(accountId: Int, articleLocalId: String) -> Note? {
        let account = ApiAccount.get(accountId)
        let article = account?.articles.filter("localId == '\(articleLocalId)'").first
        return article?.note
    }

    static func get(tagId: Int) -> Results<Note> {
        let realm = try! Realm()
        return realm.objects(Note.self).filter("ANY tags.id == \(tagId)")
    }

    static func add(_ note: Note) throws {
        let realm = try! Realm()
        try realm.write {
            if let _ = realm.object(ofType: Note.self, forPrimaryKey: note.id) {
                throw DataModelError.PrimaryKeyViolation
            }
            realm.add(note)
        }
    }

    static func add(_ note: Note, to article: Article) throws {
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

    static func update(note: Note, body: String) throws {
        let realm = try! Realm()
        try realm.write {
            if realm.object(ofType: Note.self, forPrimaryKey: note.id) == nil {
                throw DataModelError.NecessaryDataDoesNotExist("ノートが存在しません")
            }
            note.body = body
            realm.add(note, update: true)
        }
    }

    static func delete(note: Note) {
        let realm = try! Realm()
        try! realm.write {
            if realm.object(ofType: Note.self, forPrimaryKey: note.id) == nil {
                return
            }
            realm.delete(note)
        }
    }
}
