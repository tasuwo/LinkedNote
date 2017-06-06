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
    @IBAction func didPressNoteButton(_ sender: Any) {
        self.delegate?.didPressNoteButton(self.article?.note)
    }
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var expr: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    var article: Article?
}
