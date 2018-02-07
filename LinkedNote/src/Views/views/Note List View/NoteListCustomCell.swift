//
//  NoteListCustomCell.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class NoteListCustomCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var api: UILabel!
    @IBOutlet var account: UILabel!
    @IBOutlet var body: UILabel!
    var note: Note?
}
