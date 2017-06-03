//
//  TagListPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class TagListPresenter: NSObject {
    private(set) var tags: Array<Tag> = []
    
    func load() {
        tags = []
        for tag in Tag.getAll() {
            self.tags.append(tag)
        }
    }
}

extension TagListPresenter: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newCell = tableView.dequeueReusableCell(withIdentifier: "TagListCustomCell", for: indexPath) as! TagListCustomCell
        
        let tag = self.tags[indexPath.row]
        newCell.tagName.text = tag.name
        newCell.tagId = tag.id
        
        return newCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {}
}
