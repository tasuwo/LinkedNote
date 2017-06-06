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
    
    convenience init (body: String) {
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
        return realm.objects(Note.self).filter("id == \(id)").first
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
    
    static func add(_ note: Note) {
        let realm = try! Realm()
        try! realm.write {
            if realm.object(ofType: Note.self, forPrimaryKey: note.id) != nil {
                realm.create(Note.self, value: note, update: true)
            } else {
                realm.add(note)
            }
        }
    }
    
    static func add(_ note: Note, to article: Article) {
        let realm = try! Realm()
        try! realm.write {
            article.notes.append(note)
            realm.add(article, update: true)
        }
    }
    
    static func update(note: Note, body: String) {
        let realm = try! Realm()
        try! realm.write {
            note.body = body
            realm.add(note, update: true)
        }
    }
    
    static func delete(note: Note) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(note)
        }
    }
}
