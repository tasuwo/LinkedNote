//
//  FakeThumbnailDownloader.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/06.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import Foundation
@testable import LinkedNote
import UIKit

class FakeThumbnailDownloader: NSObject, ThumbnailDownloader {
    let article: Article
    let handler: (() -> Void)
    var isDownloading = true
    static var willExecuteHandler = true

    required init(article: Article, handler: @escaping (() -> Void)) {
        self.article = article
        self.handler = handler
    }

    func startDownload() {
        isDownloading = true
        if FakeThumbnailDownloader.willExecuteHandler {
            article.thumbnail = UIImage()
            isDownloading = false
            handler()
        }
    }

    func cancelDownload() {
        isDownloading = false
    }
}
