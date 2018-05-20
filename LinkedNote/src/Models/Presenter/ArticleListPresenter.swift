//
//  MyListPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import SwiftyJSON
import UIKit

enum ArticleListPresenterErrorAt {
    case Retrieve
    case Archive
}

protocol ArticleListPresenterErrorHandler {
    func occured(_: APIError, at: ArticleListPresenterErrorAt)
}

protocol ArticleListPresenterObserver {
    func loaded()
}

protocol RecognizableLongPress {
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer)
}

class ArticleListPresenter<T: ThumbnailDownloader>: NSObject, UITableViewDataSource {
    // TODO: 削除された Article オブジェクトにアクセスしようとすると例外が走るのでどうにかする
    var articles: Array<Article> = []
    var thumbnailDownloadersInProgress: Dictionary<IndexPath, ThumbnailDownloader> = [:]
    var recognizer: ArticleListViewController?
    var observer: ArticleListPresenterObserver?
    var api: APIWrapper!
    var errorObserver: ArticleListPresenterErrorHandler?

    init(api: APIWrapper, loadUnitNum: Int) {
        self.api = api
        self.api.setUnitNum(loadUnitNum)
    }

    func initOffset() {
        self.articles = []
        self.api.initOffset()
        self.observer?.loaded()
    }

    func retrieve() {
        self.api.retrieve({ infoArray, error in
            if let e = error {
                self.errorObserver?.occured(e, at: .Retrieve)
                return
            }
            self.articles += infoArray
            self.observer?.loaded()
        })
    }

    func retrieveArchive() {
        self.api.retrieveArchives({ infoArray, error in
            if let e = error {
                self.errorObserver?.occured(e, at: .Retrieve)
                return
            }
            self.articles += infoArray
            self.observer?.loaded()
        })
    }

    func archiveRow(at indexPath: IndexPath, id: String, handler: @escaping () -> Void) {
        self.api.archive(id: id, completion: { error in
            if let e = error {
                self.errorObserver?.occured(e, at: .Archive)
                return
            }
            self.articles.remove(at: indexPath.row)
            handler()
        })
    }

    func deleteRow(at indexPath: IndexPath, id: String, handler: @escaping () -> Void) {
        self.api.delete(id: id, completion: { error in
            if let e = error {
                self.errorObserver?.occured(e, at: .Archive)
                return
            }
            self.articles.remove(at: indexPath.row)
            handler()
        })
    }

    func readdRow(at indexPath: IndexPath, id: String, handler: @escaping () -> Void) {
        self.api.readd(id: id, completion: { error in
            if let e = error {
                self.errorObserver?.occured(e, at: .Archive)
                return
            }
            self.articles.remove(at: indexPath.row)
            handler()
        })
    }

    func startThumbnailDownload(article: Article, forIndexPath indexPath: IndexPath, tableView: UITableView) {
        guard self.thumbnailDownloadersInProgress[indexPath] == nil else {
            return
        }
        if article.thumbnailUrl == "" {
            return
        }
        let downloader = T(article: article, handler: { () in
            let cell = tableView.cellForRow(at: indexPath)
            cell?.imageView?.image = article.thumbnail
            cell?.setNeedsLayout()

            self.thumbnailDownloadersInProgress.removeValue(forKey: indexPath)
        })
        self.thumbnailDownloadersInProgress[indexPath] = downloader
        downloader.startDownload()
    }

    // MARK: UITableViewDataSource

    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "ArticleListCustomCell", for: indexPath) as! ArticleListCustomCell

        let article = self.articles[indexPath.row]
        newCell.article = article
        newCell.label?.text = article.title
        newCell.expr?.text = article.excerpt

        if let thumbanail = article.thumbnail {
            newCell.imageView!.image = thumbanail
        } else {
            self.startThumbnailDownload(article: article, forIndexPath: indexPath, tableView: tableView)
            newCell.imageView!.image = UIImage.colorImage(
                color: UIColor(r: 220, g: 220, b: 220),
                // TODO: Research for the situation that the thumbnail is nil
                size: newCell.thumbnail?.frame.size ?? CGSize.zero
            )
        }
        let v = tableView as! ArticleListTableView
        newCell.delegate = v

        // Set image
        newCell.noteButton.setImage(UIImage(named: "note_enable"), for: .normal)
        newCell.noteButton.setImage(UIImage(named: "note_disable"), for: .disabled)

        // Check existence of note
        if let _ = article.note {
            newCell.noteButton.isEnabled = true
        } else {
            newCell.noteButton.isEnabled = false
        }

        // Add recognizer
        // For recognize long press to table cell
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(
            target: recognizer,
            action: #selector(recognizer!.handleLongPress)
        )
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = recognizer
        newCell.noteButton.addGestureRecognizer(longPressGesture)
        newCell.noteButton.tag = indexPath.row

        // No color puts to selected cell
        newCell.selectionStyle = UITableViewCellSelectionStyle.none

        return newCell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.articles.count
    }

    func tableView(_: UITableView, commit _: UITableViewCellEditingStyle, forRowAt _: IndexPath) {}
}
