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
    let notes = LinkingObjects(fromType: Note.self, property: "tags")

    override static func primaryKey() -> String? {
        return "id"
    }

    static func lastId() -> Int {
        let realm = try! Realm()
        return realm.objects(Tag.self).max(ofProperty: "id") ?? -1
    }

    convenience init(name: String) {
        self.init()
        self.id = Tag.lastId() + 1
        self.name = name
    }
}

// MARK: - Entity model methods

extension RepositoryProtocol where Self: Repository<Tag> {
    func findBy(noteId: Int) -> Results<Tag> {
        return find(predicate: NSPredicate(format: "ANY notes.id == %@", argumentArray: [noteId]))
    }

    func add(_ tag: Tag) throws {
        let realm = try! Realm()
        try realm.write {
            if let _ = realm.object(ofType: Tag.self, forPrimaryKey: tag.id) {
                throw DataModelError.PrimaryKeyViolation
            }
            realm.add(tag)
        }
    }

    func add(_ tag: Tag, to note: Note) throws {
        let realm = try! Realm()
        try realm.write {
            if realm.object(ofType: Tag.self, forPrimaryKey: tag.id) == nil {
                throw DataModelError.NecessaryDataDoesNotExist("タグが存在しません")
            }
            if realm.object(ofType: Note.self, forPrimaryKey: note.id) == nil {
                throw DataModelError.NecessaryDataDoesNotExist("ノートが存在しません")
            }

            note.tags.append(tag)
            realm.add(note, update: true)
        }
    }

    func delete(_ tagId: Int, from noteId: Int) throws {
        let realm = try! Realm()
        try realm.write {
            if realm.object(ofType: Tag.self, forPrimaryKey: tagId) == nil {
                throw DataModelError.NecessaryDataDoesNotExist("タグが存在しません")
            }
            guard let note = realm.object(ofType: Note.self, forPrimaryKey: noteId) else {
                throw DataModelError.NecessaryDataDoesNotExist("ノートが存在しません")
            }
            if note.tags.contains(where: { t in t.id == tagId }) == false {
                // There no specified tag which is added to note.
                return
            }
            var targetIndex: Int?
            for (i, t) in note.tags.enumerated() {
                if t.id == tagId {
                    targetIndex = i
                }
            }
            if let i = targetIndex {
                note.tags.remove(at: i)
                realm.add(note, update: true)
            }
        }
    }
}
