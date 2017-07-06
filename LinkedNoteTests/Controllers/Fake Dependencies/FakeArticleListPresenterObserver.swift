//
//  FakeArticleListPresenterObserver.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/06.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import Foundation
@testable import LinkedNote

class FakeArticleListPresenterObserver: ArticleListPresenterObserver {
    var isLoaded = false
    func loaded() {
        isLoaded = true
    }
}
