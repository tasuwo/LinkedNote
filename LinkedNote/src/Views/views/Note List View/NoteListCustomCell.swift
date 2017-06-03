//
//  NoteListCustomCell.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class NoteListCustomCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var api: UILabel!
    @IBOutlet weak var account: UILabel!
    @IBOutlet weak var body: UILabel!
    var note: Note?
}
