//
//  NoteListView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class NoteListView: UIView {
    @IBOutlet var view_: UIView!
    fileprivate(set) var noteList: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        Bundle.main.loadNibNamed("NoteList", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)

        noteList = UITableView(frame: frame)
        noteList.rowHeight = 100
        noteList.register(UINib(nibName: "NoteListCustomCell", bundle: nil), forCellReuseIdentifier: "NoteListCustomCell")

        view_.addSubview(noteList)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
