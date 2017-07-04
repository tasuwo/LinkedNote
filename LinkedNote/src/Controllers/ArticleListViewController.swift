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
    let alertPresenter: AlertPresenter
    let tagEditViewPresenter: TagEditViewPresenter

    init(api: APIWrapper, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.api = api
        self.calculator = calculator
        self.alertPresenter = alertPresenter
        self.articleListPresenter = ArticleListPresenter(api: api, loadUnitNum: 5)
        self.tagEditViewPresenter = TagEditViewPresenter(alertPresenter: alertPresenter)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
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

    override func viewWillAppear(_: Bool) {
        self.articleListView.myList?.reloadData()
        self.tagEditViewPresenter.addObserver()
    }

    override func viewWillDisappear(_: Bool) {
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
            self.alertPresenter.error("記事の読み込みに必要な情報の取得に失敗しました", on: self)
            return
        }

        // Update article
        if cell.article?.note == nil {
            if cell.article?.id == -1 {
                cell.article!.addId()
                try! Article.add(cell.article!)
                try! Article.add(cell.article!, to: account)
                let n = Note(body: "")
                try! Note.add(n)
                try! Note.add(n, to: cell.article!)
            }
        }

        // Get updated article from database because this contains notes
        let article = Article.get(localId: cell.article!.localId, accountId: account.id)
        if article == nil {
            self.alertPresenter.error("記事の取得に失敗しました", on: self)
            return
        }

        let articleVC = ArticleViewController(article: article!, calculator: self.calculator, alertPresenter: alertPresenter)
        self.navigationController?.pushViewController(articleVC, animated: true)

        // Update cell informations
        cell.noteButton.isEnabled = true
        cell.article = article
    }

    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: "Archive", handler: { _, indexPath in
            let cell = self.articleListView.myList!.cellForRow(at: indexPath) as! ArticleListCustomCell

            self.articleListPresenter.archiveRow(at: indexPath, id: cell.article!.localId)
            self.articleListView.myList!.deleteRows(at: [indexPath], with: .automatic)
        })]
    }

    // Scrolled
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

    // The user's finger was released after dragging. Decelarate is True during inertial scrolling.
    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.articleListPresenter.loadImagesForOnscreenRows(tableView: self.articleListView.myList!)
        }
    }

    // Immediately stop scrolling
    func scrollViewDidEndDecelerating(_: UIScrollView) {
        self.articleListPresenter.loadImagesForOnscreenRows(tableView: self.articleListView.myList!)
    }
}

extension ArticleListViewController: ArticleListTableViewDelegate {
    func didPressNoteButtonOnCell(_ note: Note?) {
        if let note = note {
            let noteVC = NoteViewController(note: note, calculator: self.calculator, alertPresenter: self.alertPresenter)
            self.navigationController?.pushViewController(noteVC, animated: true)
        } else {
            alertPresenter.error("ノートが存在しません", on: self)
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
