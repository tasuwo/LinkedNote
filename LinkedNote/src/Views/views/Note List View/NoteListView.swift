//
//  NoteListView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol NoteListViewProvider {
    var view: UIView { get }
    var noteList: UITableView { get }
}

class NoteListView: UIView {
    @IBOutlet var view_: UIView!
    fileprivate(set) var noteList_: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        Bundle.main.loadNibNamed("NoteList", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)

        noteList_ = UITableView(frame: frame)
        noteList_.rowHeight = 100
        noteList_.register(UINib(nibName: "NoteListCustomCell", bundle: nil), forCellReuseIdentifier: "NoteListCustomCell")

        view_.addSubview(noteList_)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteListView: NoteListViewProvider {
    var view: UIView {
        return self.view_
    }

    var noteList: UITableView {
        return self.noteList_
    }
}
