//
//  noteListPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import RealmSwift

class NoteListPresenter: NSObject {
    private(set) var notes: Results<Note> = Note.getAll()

    func load(_ tagId: Int?) {
        if let id = tagId {
            notes = Note.get(tagId: id)
        } else {
            notes = Note.getAll()
        }
    }
}

extension NoteListPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "NoteListCustomCell", for: indexPath) as! NoteListCustomCell

        let note = self.notes[indexPath.row]
        newCell.title.text = note.article?.title
        newCell.note = note
        newCell.api.text = note.article!.apiAccount!.api.first!.signature
        newCell.account.text = note.article!.apiAccount!.username
        newCell.body.text = note.body

        return newCell
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.notes.count
    }

    func tableView(_: UITableView, commit _: UITableViewCellEditingStyle, forRowAt _: IndexPath) {}
}
