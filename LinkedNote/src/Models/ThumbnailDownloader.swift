//
//  ThumbnailDownloader.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/04.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

let kAppIconSize: CGFloat = 55

protocol ThumbnailDownloader {
    init(article: Article, handler: @escaping (() -> Void))
    func startDownload()
    func cancelDownload()
}

class ThumbnailDownloaderImpl: NSObject, ThumbnailDownloader {
    private let article: Article
    private let completionHandler: (() -> Void)
    private var sessionTask: URLSessionDataTask!

    required init(article: Article, handler: @escaping (() -> Void)) {
        self.article = article
        self.completionHandler = handler
    }

    func startDownload() {
        guard let url = URL(string: self.article.thumbnailUrl) else {
            return
        }

        self.sessionTask = URLSession.shared.dataTask(with: URLRequest(url: url), completionHandler: {
            (data: Data?, _: URLResponse?, error: Error?) in

            if let e = error {
                if (e as NSError).code == NSURLErrorAppTransportSecurityRequiresSecureConnection { abort() }
            }

            OperationQueue.main.addOperation {
                if let data = data, let image = UIImage(data: data) {
                    // Adjust size
                    if image.size.width != kAppIconSize || image.size.height != kAppIconSize {
                        UIGraphicsBeginImageContextWithOptions(CGSize(width: kAppIconSize, height: kAppIconSize), false, 0.0)
                        image.draw(in: CGRect(x: 0, y: 0, width: kAppIconSize, height: kAppIconSize))
                        self.article.thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                    } else {
                        self.article.thumbnail = image
                    }
                }
                self.completionHandler()
            }
        })
        self.sessionTask.resume()
    }

    func cancelDownload() {
        self.sessionTask?.cancel()
        self.sessionTask = nil
    }
}
