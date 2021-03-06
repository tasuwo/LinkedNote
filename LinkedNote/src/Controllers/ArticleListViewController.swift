//
//  MyListViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class ArticleListViewController: UIViewController {
    let provider: ArticleListViewProvider
    let refreshControl: UIRefreshControl
    let articleListPresenter: ArticleListPresenter<ThumbnailDownloaderImpl>
    let api: APIWrapper
    let calculator: FrameCalculator
    let alertPresenter: AlertPresenter
    let tagEditViewPresenter: TagEditViewPresenter

    let accountRepository: Repository<ApiAccount>
    let articleRepository: Repository<Article>
    let noteRepository: Repository<Note>

    // TODO: 挙動に関わる設定値は、どこか外部にまとめて切り出す？
    let SCROLLING_PERCENTAGE_WHICH_TRIGGER_UPDATE: CGFloat = 0.9
    let NUM_OF_ARTICLES_LOADED_AT_ONCE: Int = 20

    var cellHeightList: [IndexPath: CGFloat] = [:]

    init(provider: ArticleListViewProvider, api: APIWrapper, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.provider = provider
        self.api = api
        self.calculator = calculator
        self.alertPresenter = alertPresenter
        self.articleListPresenter = ArticleListPresenter(api: api, loadUnitNum: NUM_OF_ARTICLES_LOADED_AT_ONCE)
        self.tagEditViewPresenter = TagEditViewPresenter(alertPresenter: alertPresenter)
        self.refreshControl = UIRefreshControl()
        // TODO: Factory pattern
        self.accountRepository = Repository<ApiAccount>()
        self.articleRepository = Repository<Article>()
        self.noteRepository = Repository<Note>()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize and add a view
        self.provider.view.frame = self.calculator.calcFrameOnTabAndNavBar(by: self)
        self.provider.articleTableView.frame = self.calculator.calcFrameOnTabAndNavBar(by: self)
        self.view.addSubview(self.provider.view)

        // Prepare a presenter
        self.articleListPresenter.observer = self.provider.observer
        self.articleListPresenter.recognizer = self
        self.articleListPresenter.initOffset()

        // Prepare the table view
        self.provider.articleTableView.dataSource = articleListPresenter
        self.provider.articleTableView.delegate = self
        self.provider.setDelegate(delegate: self)
        self.provider.setArticleTableViewDelegate(delegate: self)

        // Update model and display them on the table view
        if type(of: api).isLoggedIn() {
            self.articleListPresenter.retrieve()
        }

        self.refreshControl.addTarget(self, action: #selector(self.refresh), for: .valueChanged)
        self.provider.articleTableView.addSubview(self.refreshControl)

        self.articleListPresenter.errorObserver = self

        self.navigationItem.title = "マイリスト"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_: Bool) {
        if !type(of: api).isLoggedIn() {
            self.articleListPresenter.initOffset()
        }

        if type(of: api).isLoggedIn() && self.provider.articleTableView.numberOfRows(inSection: 0) == 0 {
            self.articleListPresenter.initOffset()
            self.articleListPresenter.retrieve()
        }
    }

    // viewWillAppear で追加を行うと、画面遷移内にメソッドがトリガーされておかしな挙動になるので、
    // 読み込んでから追加する
    override func viewDidAppear(_: Bool) {
        self.tagEditViewPresenter.addObserver()
    }

    override func viewWillDisappear(_: Bool) {
        self.tagEditViewPresenter.removeObserver()
    }
}

extension ArticleListViewController {
    func refresh() {
        guard let state = self.provider.articleListState else {
            // TODO: Error Handling
            return
        }

        self.articleListPresenter.initOffset()

        switch state {
        case .ARCHIVE:
            self.articleListPresenter.retrieveArchive()
        case .UNREAD:
            self.articleListPresenter.retrieve()
        }
        self.refreshControl.endRefreshing()
    }
}

extension ArticleListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! ArticleListCustomCell

        let signature = type(of: self.api).signature

        guard let username = type(of: self.api).getUsername() else {
            self.alertPresenter.error("ユーザ情報の取得に失敗しました", on: self)
            return
        }

        guard let account = accountRepository.find(apiSignature: signature, username: username) else {
            self.alertPresenter.error("アカウント情報の取得に失敗しました", on: self)
            return
        }

        guard let article = cell.article else {
            self.alertPresenter.error("記事の読み込みに必要な情報の取得に失敗しました", on: self)
            return
        }

        // Update article
        if article.note == nil {
            if cell.article?.id == -1 {
                cell.article!.addId()
                try! articleRepository.add(cell.article!)
                try! articleRepository.add(cell.article!, to: account)
                let n = Note(body: "")
                try! noteRepository.add(n)
                try! noteRepository.add(n, to: cell.article!)
            }
        }

        let articleVC = ArticleViewController(provider: ArticleView(), article: article, calculator: self.calculator, alertPresenter: alertPresenter)
        articleVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(articleVC, animated: true)

        // Update cell informations
        cell.noteButton.isEnabled = true
        cell.article = article
    }

    // Edit row
    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let state = self.provider.articleListState else {
            // TODO: Error Handling
            return []
        }

        let archiveAction = UITableViewRowAction(style: .normal, title: "Archive", handler: { _, indexPath in
            let cell = self.provider.articleTableView.cellForRow(at: indexPath) as! ArticleListCustomCell

            self.articleListPresenter.archiveRow(at: indexPath, id: cell.article!.localId, handler: { _ in
                self.provider.articleTableView.deleteRows(at: [indexPath], with: .automatic)
            })
        })
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { _, indexPath in
            let cell = self.provider.articleTableView.cellForRow(at: indexPath) as! ArticleListCustomCell

            self.articleListPresenter.deleteRow(at: indexPath, id: cell.article!.localId, handler: { _ in
                self.provider.articleTableView.deleteRows(at: [indexPath], with: .automatic)
            })
        })
        let readdAction = UITableViewRowAction(style: .normal, title: "Readd", handler: { _, indexPath in
            let cell = self.provider.articleTableView.cellForRow(at: indexPath) as! ArticleListCustomCell

            self.articleListPresenter.readdRow(at: indexPath, id: cell.article!.localId, handler: { _ in
                self.provider.articleTableView.deleteRows(at: [indexPath], with: .automatic)
            })
        })

        switch state {
        case .ARCHIVE:
            return [deleteAction, readdAction]
        case .UNREAD:
            return [deleteAction, archiveAction]
        }
    }

    // Scrolled
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let state = self.provider.articleListState else {
            // TODO: Error Handling
            return
        }

        if self.refreshControl.isRefreshing {
            return
        }

        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset

        if offset.y > ((size.height * SCROLLING_PERCENTAGE_WHICH_TRIGGER_UPDATE) - (bounds.height - inset.bottom)) {
            switch state {
            case .ARCHIVE:
                self.articleListPresenter.retrieveArchive()
            case .UNREAD:
                self.articleListPresenter.retrieve()
            }
        }
    }
}

extension ArticleListViewController: ArticleListTableViewDelegate {
    func didPressNoteButtonOnCell(_ note: Note?) {
        if let note = note {
            let noteVC = NoteViewController(provider: NoteView(), note: note, calculator: self.calculator, alertPresenter: self.alertPresenter, tagEditViewPresenter: TagEditViewPresenter(alertPresenter: self.alertPresenter))
            self.navigationController?.pushViewController(noteVC, animated: true)
        } else {
            alertPresenter.error("ノートが存在しません", on: self)
        }
    }
}

extension ArticleListViewController: ArticleListViewProtocol {
    func didChangeMyListState(_ state: ArticleListSegmentState?) {
        guard let s = state else {
            // TODO: Error handling
            return
        }

        self.articleListPresenter.initOffset()

        switch s {
        case .UNREAD:
            self.articleListPresenter.retrieve()
        case .ARCHIVE:
            self.articleListPresenter.retrieveArchive()
        }
    }
}

extension ArticleListViewController: UIGestureRecognizerDelegate, RecognizableLongPress {
    @objc func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let tag = longPressGestureRecognizer.view!.tag
            let cell = self.provider.articleTableView.cellForRow(at: IndexPath(row: tag, section: 0)) as? ArticleListCustomCell

            self.tagEditViewPresenter.initwith(provider: TagMenuView(), note: cell!.article!.note!, frame: self.tabBarController!.view.frame)
            self.tagEditViewPresenter.add(to: self.tabBarController!.view, viewController: self)
        }
    }
}

extension ArticleListViewController: ArticleListPresenterErrorHandler {
    func occured(_ error: APIError, at type: ArticleListPresenterErrorAt) {
        let title: String
        switch type {
        case .Archive:
            title = "記事の削除に失敗しました"
        case .Retrieve:
            title = "記事一覧の取得に失敗しました"
        }

        let body: String
        switch error {
        case .APIError:
            body = "001"
        case .FailedToGetUserNameByAPI:
            body = "002"
        case .NotLoggedIn:
            body = "003"
        case .ResponseIsNil:
            body = "004"
        case .UnexpectedAPIResponseFormat:
            body = "005"
        case .UserNotFoundInDatabase:
            body = "006"
        }

        self.alertPresenter.error("\(title)\n エラーコード: \(body)", on: self)
    }
}
