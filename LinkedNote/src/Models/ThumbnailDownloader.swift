//
//  ThumbnailDownloader.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/04.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

let kAppIconSize: CGFloat = 100

class ThumbnailDownloader: NSObject {
    var articleInfo: ArticleInfo!
    var completionHandler: (() -> Void)!
    private var sessionTask: URLSessionDataTask!
    
    func startDownload() {
        if let url = URL(string: self.articleInfo.thumbnailUrl) {
            let request = URLRequest(url: url)
            self.sessionTask = URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                if let e = error {
                    if (e as NSError).code == NSURLErrorAppTransportSecurityRequiresSecureConnection { abort() }
                }
                
                OperationQueue.main.addOperation {
                    if let data = data,
                       let image = UIImage(data: data) {
                        if image.size.width != kAppIconSize || image.size.height != kAppIconSize {
                            let itemSize = CGSize(width: kAppIconSize, height: kAppIconSize)
                            UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
                            let imageRect = CGRect(x: 0, y: 0, width: itemSize.width, height: itemSize.height)
                            image.draw(in: imageRect)
                            self.articleInfo.thumbnail = UIGraphicsGetImageFromCurrentImageContext()
                            UIGraphicsEndImageContext()
                        } else {
                            self.articleInfo.thumbnail = image
                        }
                    }
                    
                    if let handler = self.completionHandler {
                        handler()
                    }
                }
            })
            self.sessionTask.resume()
        }
    }
    
    func cancelDownload() {
        self.sessionTask?.cancel()
        self.sessionTask = nil
    }
}
