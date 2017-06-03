//
//  MyListPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import PocketAPI
import SwiftyJSON

protocol ArticleListPresenterObserver {
    func loaded()
}

struct ArticleInfo {
    var id: String = ""
    var title: String = "No Title"
    var excerpt: String = ""
    var url: String = ""
    var thumbnailUrl: String = ""
    var thumbnail: UIImage?
}

class ArticleListPresenter: NSObject {
    var posts: Array<ArticleInfo> = []
    var recognizer: ArticleListViewController?
    var observer: ArticleListPresenterObserver?
    var api: APIWrapper!
    
    init(api: APIWrapper, loadUnitNum: Int) {
        self.api = api
        self.api.setUnitNum(loadUnitNum)
    }
    
    func initOffset() {
        self.posts = []
        self.api.initOffset()
    }
    
    func retrieve() {
        self.api.retrieve({ (infoArray) in
            self.posts += infoArray
            self.observer?.loaded()
        })
    }
}

extension ArticleListPresenter: UITableViewDataSource {
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "ArticleListCustomCell", for: indexPath) as! ArticleListCustomCell
        
        let info = self.posts[indexPath.row]
        newCell.label?.text = info.title
        newCell.expr?.text = info.excerpt
        
        // 画像の取得
        newCell.info = info
        if info.thumbnail == nil {
            newCell.thumbnail.image = nil
            if let url = NSURL(string: info.thumbnailUrl) as URL? {
                let downloader = AsyncImageDownloader()
                downloader.loadImage(url: url, completion: { (image) in
                    self.posts[indexPath.row].thumbnail = image
                    newCell.thumbnail.image = image
                })
            }
        } else {
            newCell.thumbnail.image = info.thumbnail
        }

        let v = tableView as! ArticleListTableView
        newCell.delegate = v
        
        // Set image
        newCell.noteButton.setImage(UIImage(named: "note_enable"), for: .normal)
        newCell.noteButton.setImage(UIImage(named: "note_disable"), for: .disabled)
        
        // Check existence of note
        if let account = ApiAccount.get(apiSignature: "pocket", username: ""),
           let article = Article.get(localId: info.id, accountId: account.id),
           let note = Note.get(accountId: account.id, articleLocalId: article.localId) {
            newCell.noteButton.isEnabled = true
            newCell.note = note
        } else {
            newCell.noteButton.isEnabled = false
        }
        
        // Add recognizer
        // For recognize long press to table cell
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: recognizer, action: #selector(recognizer!.handleLogPress))
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = recognizer
        newCell.noteButton.addGestureRecognizer(longPressGesture)

        return newCell
    }
    
    // Tells the data source to return the number of rows in a given section of a table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
}

class AsyncImageDownloader: NSObject {
    let CACHE_SEC : TimeInterval = 5 * 60; //5分キャッシュ
    
    //画像を非同期で読み込む
    func loadImage(url: URL, completion: @escaping (_ image: UIImage?) -> Void){
        let req = URLRequest(url: url,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: CACHE_SEC)
        let conf =  URLSessionConfiguration.default
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)
        
        session.dataTask(with: req, completionHandler:
            { (data, resp, err) in
                if((err) == nil){ //Success
                    let image = UIImage(data:data!)
                    completion(image)
                }else{ //Error
                    print("AsyncImageView:Error \(String(describing: err?.localizedDescription))")
                }
        }).resume();
    }
}

