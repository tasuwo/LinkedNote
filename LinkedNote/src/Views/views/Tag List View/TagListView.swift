//
//  TagListView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class TagListView: UIView {
    @IBOutlet var view_: UIView!
    fileprivate(set) var tagList: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        Bundle.main.loadNibNamed("TagList", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)

        tagList = UITableView(frame: frame)
        tagList.rowHeight = 100
        tagList.register(UINib(nibName: "TagListCustomCell", bundle: nil), forCellReuseIdentifier: "TagListCustomCell")

        view_.addSubview(tagList)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
