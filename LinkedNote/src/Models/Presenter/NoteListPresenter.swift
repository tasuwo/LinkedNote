//
//  noteListPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class NoteListPresenter: NSObject {
    private(set) var notes: Array<Note> = []
    
    func load(_ tagId: Int?) {
        notes = []
        if let id = tagId {
            for note in Note.get(tagId: id) {
                self.notes.append(note)
            }
        } else {
            for note in Note.getAll() {
                self.notes.append(note)
            }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {}
}
