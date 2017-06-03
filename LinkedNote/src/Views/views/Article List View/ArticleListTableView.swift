//
//  ArticleListTableView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol ArticleListTableViewDelegate {
    func didPressNoteButtonOnCell(_ note: Note?)
}

class ArticleListTableView: UITableView {
    var delegate_: ArticleListTableViewDelegate?
}

extension ArticleListTableView: ArticleListCustomCellDelegate {
    func didPressNoteButton(_ note: Note?) {
        self.delegate_?.didPressNoteButtonOnCell(note)
    }
}
