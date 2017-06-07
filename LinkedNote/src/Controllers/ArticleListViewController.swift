//
//  MyListViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class ArticleListViewController: TagEditableViewController {
    var articleListView: ArticleListView!
    let articleListPresenter: ArticleListPresenter
    let api: APIWrapper
    
    init(api: APIWrapper) {
        self.api = api
        self.articleListPresenter = ArticleListPresenter(api: api, loadUnitNum: 5)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let offset = self.navigationController!.tabBarController!.tabBar.frame.height
            + self.navigationController!.navigationBar.frame.height
            + UIApplication.shared.statusBarFrame.height
        let frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height - offset)
        self.articleListView = ArticleListView(frame: frame)
    
        self.view.addSubview(articleListView)
        
        self.articleListPresenter.observer = articleListView
        self.articleListPresenter.recognizer = self
        self.articleListView.myList!.dataSource = articleListPresenter
        self.articleListView.myList!.delegate = self
        self.articleListView.myList!.delegate_ = self
        
        self.articleListPresenter.initOffset()
        self.articleListPresenter.retrieve()
        
        self.navigationItem.title = "マイリスト"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.articleListView.myList?.reloadData()
        
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
        
        if let article = cell.article {
            let signature = type(of: self.api).signature
            let username = type(of: self.api).getUsername()!
            let account = ApiAccount.get(apiSignature: signature, username: username)!
            
            if cell.article?.note == nil {
                if cell.article?.id == -1 {
                    article.addId()
                    Article.add(article)
                    Article.add(article, to: account)
                    let n = Note(body: "")
                    Note.add(n)
                    Note.add(n, to: article)
                }
            }
            
            if let article = Article.get(localId: article.localId, accountId: account.id) {
                let articleVC = ArticleViewController(article: article)
                self.navigationController?.pushViewController(articleVC, animated: true)
                
                // cell のボタンを有効化しておく
                cell.noteButton.isEnabled = true
                cell.article = article
            } else {
                AlertCreater.error("記事の取得に失敗しました", viewController: self)
            }
        } else {
            AlertCreater.error("記事の読み込みに必要な情報の取得に失敗しました", viewController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .default, title: "Archive", handler: { (action, indexPath) in
                let cell = self.articleListView.myList!.cellForRow(at: indexPath) as! ArticleListCustomCell

                self.articleListPresenter.archiveRow(at: indexPath, id: cell.article!.localId)
                self.articleListView.myList!.deleteRows(at: [indexPath], with: .automatic)
            })
        ]
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
            let noteVC = NoteViewController(note: note)
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
            if let indexPath = self.articleListView.myList?.indexPathForRow(at: touchPoint) {
                
                let cell = self.articleListView.myList?.cellForRow(at: indexPath) as! ArticleListCustomCell
                self.initializeTagEditView(note: cell.article!.note!)
            }
        }
    }
}

extension ArticleListViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.articleListPresenter.loadImagesForOnscreenRows(tableView: self.articleListView.myList!)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.articleListPresenter.loadImagesForOnscreenRows(tableView: self.articleListView.myList!)
    }
}

