//
//  ArticleListPresenterTest.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/05.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest
import RealmSwift
@testable import LinkedNote

class ArticleListPresenterTest: XCTestCase {
    var apiWrapper: FakeAPIWrapper!
    var presenter: ArticleListPresenter!

    override func setUp() {
        super.setUp()
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
        let api = Api(signature: "test_api")
        let account = ApiAccount(username: "test_username")
        api.accounts.append(account)
        let article1 = Article(localId: "1", title: "article1", url: "", thumbnailUrl: "")
        let article2 = Article(localId: "2", title: "article1", url: "", thumbnailUrl: "")
        account.articles.append(article1)
        account.articles.append(article2)

        let realm = try! Realm()
        try! realm.write {
            article1.addId()
            realm.add(article1)
            article2.addId()
            realm.add(article2)
            realm.add(account)
            realm.add(api)
        }

        self.apiWrapper = FakeAPIWrapper()
        FakeAPIWrapper.signature = "test_api"

        self.presenter = ArticleListPresenter(api: apiWrapper, loadUnitNum: 5)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitOffset() {
        
    }
    
    func testRetrieve() {
        
    }
    
    func testArchiveRow() {
        
    }
    
    // func startThumbnailDownload() {}
}
