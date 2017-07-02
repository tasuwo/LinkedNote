//
//  Article.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import Realm
import RealmSwift

class Article: Object {
    dynamic var id = -1
    // アカウント内でローカルに記事を識別するための ID
    // 利用する API 側で使用している ID を再利用する
    dynamic var localId = ""
    dynamic var title = ""
    dynamic var url = ""
    dynamic var excerpt = ""
    dynamic var thumbnailUrl = ""
    var thumbnail: UIImage?
    let apiAccounts = LinkingObjects(fromType: ApiAccount.self, property: "articles")
    var apiAccount: ApiAccount? {
        return self.apiAccounts.first
    }

    var notes = List<Note>()
    var note: Note? {
        return self.notes.first
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    override static func ignoredProperties() -> [String] {
        return ["thumbnail"]
    }

    static func lastId() -> Int {
        let realm = try! Realm()
        return realm.objects(Article.self).last?.id ?? -1
    }

    convenience init(localId: String, title: String, url: String, thumbnailUrl: String) {
        self.init()
        self.localId = localId
        self.title = title
        self.url = url
        self.thumbnailUrl = thumbnailUrl
    }

    func addId() {
        self.id = Article.lastId() + 1
    }
}

// MARK: - Entity model methods

extension Article {
    static func get(localId: String, accountId: Int) -> Article? {
        let realm = try! Realm()
        return realm.objects(Article.self).filter("ANY apiAccounts.id == \(accountId) AND localId == '\(localId)'").first
    }

    static func add(_ article: Article) throws {
        let realm = try! Realm()
        try realm.write {
            if article.id == -1 {
                throw DataModelError.InvalidParameter("ID が追加されていません")
            }
            if let _ = realm.object(ofType: Article.self, forPrimaryKey: article.id) {
                throw DataModelError.PrimaryKeyViolation
            }
            realm.add(article)
        }
    }

    static func add(_ article: Article, to account: ApiAccount) throws {
        let realm = try! Realm()
        try realm.write {
            if let article_ = realm.object(ofType: Article.self, forPrimaryKey: article.id) {
                if !article_.isEqual(article) {
                    throw DataModelError.InvalidParameter("保存されていない更新が含まれた記事オブジェクトです。更新を保存後に本操作を行ってください。")
                }
            } else {
                throw DataModelError.NecessaryDataDoesNotExist("記事が存在しません")
            }
            if let _ = realm.objects(Article.self).filter("ANY apiAccounts.id == \(account.id) AND localId == '\(article.localId)'").first {
                throw DataModelError.IntegrityConstraintViolation
            }
            if realm.object(ofType: ApiAccount.self, forPrimaryKey: account.id) == nil {
                throw DataModelError.NecessaryDataDoesNotExist("アカウントが存在しません")
            }
            account.articles.append(article)
            realm.add(account, update: true)
        }
    }
}
