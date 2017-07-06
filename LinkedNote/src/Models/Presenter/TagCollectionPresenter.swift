//
//  TagCollectionPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import RealmSwift

class TagCollectionPresenter: NSObject {
    private(set) var tags: Results<Tag> = Tag.getAll()

    func load(noteId: Int) {
        self.tags = Tag.get(noteId: noteId)
    }
}

extension TagCollectionPresenter: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as! TagCollectionViewCell
        cell.name?.text = tags[indexPath.row].name
        cell.name.numberOfLines = 0
        cell.id = tags[indexPath.row].id

        cell.contentView.layer.backgroundColor = UIColor.myNavigationBarColor().cgColor

        cell.contentView.layer.cornerRadius = 5.0
        cell.contentView.layer.borderWidth = 2.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.backgroundColor = UIColor.clear.cgColor

        return cell
    }
}
