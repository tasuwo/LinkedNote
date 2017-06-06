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
    
    convenience init (localId: String, title: String, url: String, thumbnailUrl: String) {
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
    
    static func add(_ article: Article) {
        if article.id == -1 {
            // TODO: throw Exception
            return
        }
        let realm = try! Realm()
        try! realm.write {
            if realm.object(ofType: Article.self, forPrimaryKey: article.id) != nil {
                realm.create(Article.self, value: article, update: true)
            } else {
                realm.add(article)
            }
        }
    }
    
    static func add(_ article: Article, to account: ApiAccount) {
        let realm = try! Realm()
        try! realm.write {
            account.articles.append(article)
            realm.add(account, update: true)
        }
    }
}
