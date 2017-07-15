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
    var articleTableView: UITableView { get }
    var observer: ArticleListPresenterObserver { get }

    func setArticleTableViewDelegate(delegate: ArticleListTableViewDelegate)
}

class ArticleListView: UIView {
    @IBOutlet var view_: UIView!
    var myList: ArticleListTableView?

    init() {
        super.init(frame: CGRect.zero)
        Bundle.main.loadNibNamed("ArticleList", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)

        myList = ArticleListTableView(frame: frame)
        myList!.rowHeight = 150
        myList!.register(UINib(nibName: "ArticleListCustomCell", bundle: nil), forCellReuseIdentifier: "ArticleListCustomCell")

        view_.addSubview(myList!)
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

    var articleTableView: UITableView {
        return self.myList!
    }

    var observer: ArticleListPresenterObserver {
        return self
    }

    func setArticleTableViewDelegate(delegate: ArticleListTableViewDelegate) {
        self.myList?.delegate_ = delegate
    }
}
