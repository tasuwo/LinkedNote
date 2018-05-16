//
//  BackupRestoreStrategy.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/10.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import Foundation

protocol BackupRestoreStrategy {
    func isAvailable() -> Bool
    func backup()
    func restore() throws
}
