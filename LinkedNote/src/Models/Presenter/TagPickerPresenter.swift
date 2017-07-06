//
//  TagPickerPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import RealmSwift

class TagPickerPresenter: NSObject {
    private(set) var tags: Results<Tag> = Tag.getAll()

    func reload() {
        self.tags = Tag.getAll()
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
