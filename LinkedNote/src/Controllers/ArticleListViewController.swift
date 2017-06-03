//
//  MyListViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import PocketAPI

class ArticleListViewController: TagEditableViewController {
    var articleListPresenter: ArticleListPresenter!
    // API informations
    // Api のシグネチャ/usernameはとりあえず直書き
    var apiSignature = "pocket"
    var username = ""
    var view_: ArticleListView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pocket API をきめうち
        let api = PocketAPIWrapper()
        articleListPresenter = ArticleListPresenter(api: api, loadUnitNum: 5)
        articleListPresenter.recognizer = self
        let offset = self.navigationController!.tabBarController!.tabBar.frame.height
            + self.navigationController!.navigationBar.frame.height
            + UIApplication.shared.statusBarFrame.height
        let frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height - offset)
        view_ = ArticleListView(frame: frame)
        articleListPresenter.observer = view_!
        view_!.myList!.dataSource = articleListPresenter
        view_!.myList!.delegate = self
        view_!.myList!.delegate_ = self
        
        self.view.addSubview(view_!)
        
        self.articleListPresenter.initOffset()
        self.articleListPresenter.retrieve()
        
        self.navigationItem.title = "マイリスト"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view_?.myList?.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tagEditKeyboardWillBeShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tagEditKeyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ArticleListCustomCell
        
        if let info = cell.info {
            var note: Note? = nil

            if let n = Note.get(signature: self.apiSignature, username: self.username, articleInfo: info) {
                note = n
            } else {
                // Note が存在しなければ作成する
                let account = ApiAccount.get(apiSignature: self.apiSignature, username: self.username)!
                if let article = Article.get(localId: info.id, accountId: account.id) {
                    let n = Note(body: "")
                    Note.add(n)
                    Note.add(n, to: article)
                    note = n
                } else {
                    // Article が存在しなければ作成する
                    let article = Article(localId: info.id, title: info.title, url: info.url, thumbnailUrl: info.thumbnailUrl)
                    Article.add(article)
                    Article.add(article, to: account)
                    let n = Note(body: "")
                    Note.add(n)
                    Note.add(n, to: article)
                    note = n
                }
            }
            
            let articleVC = ArticleViewController()
            articleVC.info = cell.info
            articleVC.note = note
            self.navigationController?.pushViewController(articleVC, animated: true)
            
            // cell のボタンを有効化しておく
            cell.noteButton.isEnabled = true
            cell.note = note
        } else {
            AlertCreater.error("記事の読み込みに必要な情報の取得に失敗しました", viewController: self)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom
        let h = size.height
        
        let reloadDistance: CGFloat = 10
        if y > h + reloadDistance {
            self.articleListPresenter.retrieve()
        }
    }
}

extension ArticleListViewController: ArticleListTableViewDelegate {
    func didPressNoteButtonOnCell(_ note: Note?) {
        if let note = note {
            let noteVC = NoteViewController()
            noteVC.note = note
            self.navigationController?.pushViewController(noteVC, animated: true)
        }
    }
}

protocol RecognizableLongPress {
    func handleLogPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer)
}

extension ArticleListViewController: UIGestureRecognizerDelegate, RecognizableLongPress {
    @objc func handleLogPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = self.view_?.myList?.indexPathForRow(at: touchPoint) {
                
                let cell = self.view_!.myList?.cellForRow(at: indexPath) as! ArticleListCustomCell
                self.initializeTagEditView(note: cell.note!)
            }
        }
    }
}

