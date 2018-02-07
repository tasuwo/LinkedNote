//
//  TagListPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import RealmSwift
import UIKit

class TagListPresenter: NSObject {
    private let tagRepository: Repository<Tag>
    private(set) var tags: Results<Tag>

    override init() {
        self.tagRepository = Repository<Tag>()
        self.tags = self.tagRepository.findAll()
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

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return self.tags.count
    }

    func tableView(_: UITableView, commit _: UITableViewCellEditingStyle, forRowAt _: IndexPath) {}
}
