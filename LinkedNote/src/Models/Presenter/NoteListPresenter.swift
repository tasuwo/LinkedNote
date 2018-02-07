//
//  noteListPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import RealmSwift
import UIKit

class NoteListPresenter: NSObject {
    private let noteRepository: Repository<Note>
    private(set) var notes: Results<Note>

    override init() {
        // TODO: Factory pattern
        noteRepository = Repository<Note>()
        notes = noteRepository.findAll()
    }

    func load(_ tagId: Int?) {
        if let id = tagId {
            notes = noteRepository.findBy(tagId: id)
        } else {
            notes = noteRepository.findAll()
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
