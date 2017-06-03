//
//  MyListView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class ArticleListView: UIView {
    @IBOutlet var view_: UIView!
    var myList: ArticleListTableView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        Bundle.main.loadNibNamed("ArticleList", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
        
        myList = ArticleListTableView(frame: frame)
        myList!.rowHeight = 130
        myList!.register(UINib(nibName: "ArticleListCustomCell", bundle: nil), forCellReuseIdentifier: "ArticleListCustomCell")

        view_.addSubview(myList!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleListView: ArticleListPresenterObserver {
    func loaded() {
        self.myList!.reloadData()
    }
}
