//
//  TagPickerPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import RealmSwift
import UIKit

class TagPickerPresenter: NSObject {
    private let tagRepository: Repository<Tag>
    private(set) var tags: Results<Tag>

    override init() {
        self.tagRepository = Repository<Tag>()
        self.tags = self.tagRepository.findAll()
    }

    func reload() {
        self.tags = tagRepository.findAll()
    }
}

extension TagPickerPresenter: UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return tags.count
    }
}
