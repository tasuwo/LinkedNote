//
//  MyListCustomCell.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol ArticleListCustomCellDelegate {
    func didPressNoteButton(_ note: Note?)
}

class ArticleListCustomCell: UITableViewCell {
    var delegate: ArticleListCustomCellDelegate?
    @IBAction func didPressNoteButton(_: Any) {
        self.delegate?.didPressNoteButton(self.article?.note)
    }

    @IBOutlet var noteButton: UIButton!
    @IBOutlet var expr: UILabel!
    @IBOutlet var label: UILabel!
    @IBOutlet var url: UILabel!
    @IBOutlet var thumbnail: UIImageView!
    var article: Article?

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.preferredMaxLayoutWidth = self.label.bounds.width
        self.expr.preferredMaxLayoutWidth = self.expr.bounds.width
        self.url.preferredMaxLayoutWidth = self.url.bounds.width
    }
}
