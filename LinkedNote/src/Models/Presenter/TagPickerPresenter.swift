//
//  TagPickerPresenter.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class TagPickerPresenter: NSObject {
    private(set) var tags: Array<Tag> = []
    
    func reload() {
        self.tags = []
        for tag in Tag.getAll() {
            self.tags.append(tag)
        }
    }
}

extension TagPickerPresenter: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tags.count
    }
}
