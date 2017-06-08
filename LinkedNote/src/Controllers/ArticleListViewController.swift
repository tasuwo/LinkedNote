//
//  MyListViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {
    var articleListView: ArticleListView!
    let articleListPresenter: ArticleListPresenter
    let api: APIWrapper
    let calculator: FrameCalculator
    let tagEditViewPresenter: TagEditViewPresenter
    
    init(api: APIWrapper, calculator: FrameCalculator) {
        self.api = api
        self.calculator = calculator
        self.articleListPresenter = ArticleListPresenter(api: api, loadUnitNum: 5)
        self.tagEditViewPresenter = TagEditViewPresenter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize and add a view
        self.articleListView = ArticleListView(frame: self.calculator.calcFrameOnTabAndNavBar(by: self))
        self.view.addSubview(articleListView)
        
        // Prepare a presenter
        self.articleListPresenter.observer = articleListView
        self.articleListPresenter.recognizer = self
        self.articleListPresenter.initOffset()
        
        // Prepare the table view
        self.articleListView.myList!.dataSource = articleListPresenter
        self.articleListView.myList!.delegate = self
        self.articleListView.myList!.delegate_ = self
        
        // Update model and display them on the table view
        self.articleListPresenter.retrieve()
        
        self.navigationItem.title = "マイリスト"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.articleListView.myList?.reloadData()
        self.tagEditViewPresenter.addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tagEditViewPresenter.removeObserver()
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ArticleListCustomCell
        let signature = type(of: self.api).signature
        let username = type(of: self.api).getUsername()!
        let account = ApiAccount.get(apiSignature: signature, username: username)!
        
        if cell.article == nil {
            AlertCreater.error("記事の読み込みに必要な情報の取得に失敗しました", viewController: self)
            return
        }
        
        // Update article
        if cell.article?.note == nil {
            if cell.article?.id == -1 {
                cell.article!.addId()
                Article.add(cell.article!)
                Article.add(cell.article!, to: account)
                let n = Note(body: "")
                Note.add(n)
                Note.add(n, to: cell.article!)
            }
        }
        
        // Get updated article from database because this contains notes
        let article = Article.get(localId: cell.article!.localId, accountId: account.id)
        if article == nil {
            AlertCreater.error("記事の取得に失敗しました", viewController: self)
            return
        }
        
        let articleVC = ArticleViewController(article: article!, calculator: self.calculator)
        self.navigationController?.pushViewController(articleVC, animated: true)
        
        // Update cell informations
        cell.noteButton.isEnabled = true
        cell.article = article
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [ UITableViewRowAction(style: .default, title: "Archive", handler: { (action, indexPath) in
            let cell = self.articleListView.myList!.cellForRow(at: indexPath) as! ArticleListCustomCell
                
            self.articleListPresenter.archiveRow(at: indexPath, id: cell.article!.localId)
            self.articleListView.myList!.deleteRows(at: [indexPath], with: .automatic)
        }) ]
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
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.articleListPresenter.loadImagesForOnscreenRows(tableView: self.articleListView.myList!)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.articleListPresenter.loadImagesForOnscreenRows(tableView: self.articleListView.myList!)
    }
}

extension ArticleListViewController: ArticleListTableViewDelegate {
    func didPressNoteButtonOnCell(_ note: Note?) {
        if let note = note {
            let noteVC = NoteViewController(note: note, calculator: self.calculator)
            self.navigationController?.pushViewController(noteVC, animated: true)
        }
    }
}

extension ArticleListViewController: UIGestureRecognizerDelegate, RecognizableLongPress {
    @objc func handleLogPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let tag = longPressGestureRecognizer.view!.tag
            let cell = self.articleListView.myList?.cellForRow(at: IndexPath(row: tag, section: 0)) as? ArticleListCustomCell
            self.tagEditViewPresenter.initwith(note: cell!.article!.note!, frame: self.tabBarController!.view.frame)
            self.tagEditViewPresenter.add(to: self.tabBarController!.view, viewController: self)
        }
    }
}
