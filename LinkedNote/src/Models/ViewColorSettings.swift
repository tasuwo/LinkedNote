//
//  ViewColorSettings.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2018/02/23.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol ViewColorSettings {
    func getTintColor() -> UIColor!
}

extension UIView: ViewColorSettings {
    func getTintColor() -> UIColor! {
        return self.tintColor
    }
}
