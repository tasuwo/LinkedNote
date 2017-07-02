//
//  Tag.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import Realm
import RealmSwift

class Tag: Object {
    dynamic var id = 0
    dynamic var name = ""
    private let notes = LinkingObjects(fromType: Note.self, property: "tags")

    override static func primaryKey() -> String? {
        return "id"
    }

    static func lastId() -> Int {
        let realm = try! Realm()
        return realm.objects(Tag.self).last?.id ?? -1
    }

    convenience init(name: String) {
        self.init()
        self.id = Tag.lastId() + 1
        self.name = name
    }
}

// MARK: - Entity model methods

extension Tag {
    static func getAll() -> Results<Tag> {
        let realm = try! Realm()
        return realm.objects(Tag.self)
    }

    static func get(_ id: Int) -> Tag? {
        let realm = try! Realm()
        return realm.objects(Tag.self).filter("id == \(id)").first
    }

    static func get(noteId: Int) -> Results<Tag> {
        let realm = try! Realm()
        return realm.objects(Tag.self).filter("ANY notes.id == \(noteId)")
    }

    static func add(_ tag: Tag) {
        let realm = try! Realm()
        try! realm.write {
            if realm.object(ofType: Tag.self, forPrimaryKey: tag.id) != nil {
                realm.create(Tag.self, value: tag, update: true)
            } else {
                realm.add(tag)
            }
        }
    }

    static func add(_ tag: Tag, to note: Note) {
        let realm = try! Realm()
        try! realm.write {
            note.tags.append(tag)
            realm.add(note, update: true)
        }
    }

    static func delete(_ tagId: Int, from noteId: Int) {
        if let note = Note.get(noteId) {
            let realm = try! Realm()
            try! realm.write {
                var targetIndex: Int?
                for (i, t) in note.tags.enumerated() {
                    if t.id == tagId {
                        targetIndex = i
                    }
                }
                if let i = targetIndex {
                    note.tags.remove(objectAtIndex: i)
                    realm.add(note, update: true)
                }
            }
        }
    }

    static func delete(_ tag: Tag) {
        let realm = try! Realm()
        try! realm.write {
            realm.delete(tag)
        }
    }
}
