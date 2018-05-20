//
//  MyListView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol ArticleListViewProvider {
    var view: UIView { get }
    var articleListState: ArticleListSegmentState? { get }
    var articleTableView: UITableView { get }
    var observer: ArticleListPresenterObserver { get }

    func setDelegate(delegate: ArticleListViewProtocol)
    func setArticleTableViewDelegate(delegate: ArticleListTableViewDelegate)
}

protocol ArticleListViewProtocol {
    func didChangeMyListState(_ state: ArticleListSegmentState?)
}

enum ArticleListSegmentState {
    case UNREAD
    case ARCHIVE

    static func getStateBy(index: Int) -> ArticleListSegmentState? {
        switch index {
        case 0:
            return .UNREAD
        case 1:
            return .ARCHIVE
        default:
            return nil
        }
    }
}

class ArticleListView: UIView {
    @IBOutlet var view_: UIView!
    @IBOutlet var myList: ArticleListTableView!
    @IBOutlet var myListState: UISegmentedControl!
    @IBAction func didChangeMyListState(_: Any) {
        self.delegate?.didChangeMyListState(
            ArticleListSegmentState.getStateBy(index: myListState.selectedSegmentIndex)
        )
    }

    var delegate: ArticleListViewProtocol?

    init() {
        super.init(frame: CGRect.zero)
        Bundle.main.loadNibNamed("ArticleList", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)

        // myList!.rowHeight = 80
        // myList!.rowHeight = 100
        myList!.rowHeight = UITableViewAutomaticDimension
        myList!.register(UINib(nibName: "ArticleListCustomCell", bundle: nil), forCellReuseIdentifier: "ArticleListCustomCell")

        // view_.addSubview(myList_!)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleListView: ArticleListPresenterObserver {
    func loaded() {
        self.myList!.reloadData()
    }
}

extension ArticleListView: ArticleListViewProvider {
    var view: UIView {
        return self
    }

    var articleListState: ArticleListSegmentState? {
        return ArticleListSegmentState.getStateBy(index: self.myListState.selectedSegmentIndex)
    }

    var articleTableView: UITableView {
        return self.myList!
    }

    var observer: ArticleListPresenterObserver {
        return self
    }

    func setDelegate(delegate: ArticleListViewProtocol) {
        self.delegate = delegate
    }

    func setArticleTableViewDelegate(delegate: ArticleListTableViewDelegate) {
        self.myList?.delegate_ = delegate
    }
}
