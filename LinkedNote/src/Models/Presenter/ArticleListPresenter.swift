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

class ArticleInfo: NSObject {
    var id: String = ""
    var title: String = "No Title"
    var excerpt: String = ""
    var url: String = ""
    var thumbnailUrl: String = ""
    var thumbnail: UIImage?
    
    override init() {}
}

class ArticleListPresenter: NSObject {
    var posts: Array<ArticleInfo> = []
    var thumbnailDownloadersInProgress: Dictionary<IndexPath, ThumbnailDownloader> = [:]
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
    
    func archiveRow(at indexPath: IndexPath, id: String) {
        self.api.archive(id: id, completion: { (isSucceeded) in })
        self.posts.remove(at: indexPath.row)
    }
    
    func startThumbnailDownload(articleInfo info: ArticleInfo, forIndexPath indexPath: IndexPath, tableView: UITableView) {
        if nil == self.thumbnailDownloadersInProgress[indexPath] {
            let downloader = ThumbnailDownloader()
            downloader.articleInfo = info
            downloader.completionHandler = { () in
                let cell = tableView.cellForRow(at: indexPath)

                cell?.imageView?.image = info.thumbnail
                cell?.setNeedsLayout()

                self.thumbnailDownloadersInProgress.removeValue(forKey: indexPath)
            }
            self.thumbnailDownloadersInProgress[indexPath] = downloader
            downloader.startDownload()
        }
    }
    
    func loadImagesForOnscreenRows(tableView: UITableView) {
        if self.posts.count > 0 {
            if let visiblePaths = tableView.indexPathsForVisibleRows {
                for indexPath in visiblePaths {
                    let info = self.posts[indexPath.row]
                    if info.thumbnail == nil {
                        self.startThumbnailDownload(articleInfo: info, forIndexPath: indexPath, tableView: tableView)
                    }
                }
            }
        }
    }
}

extension ArticleListPresenter: UITableViewDataSource {
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "ArticleListCustomCell", for: indexPath) as! ArticleListCustomCell
        
        let info = self.posts[indexPath.row]
        newCell.label?.text = info.title
        newCell.expr?.text = info.excerpt
        newCell.info = info
        
        if let thumbanail = info.thumbnail {
            newCell.imageView!.image = thumbanail
        } else {
            if tableView.isDragging == false && tableView.isDecelerating == false {
                self.startThumbnailDownload(articleInfo: info, forIndexPath: indexPath, tableView: tableView)
            }
            newCell.imageView!.image = UIImage(named: "")
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {}
}

