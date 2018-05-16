//
//  AppSettings.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/09.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import Foundation

class AppSettings {
    private static let PATH = "test.plist"
    private static let KEY_IS_BACKUP = "isBackup"

    private static func applicationSupportDir() -> URL {
        if TARGET_IPHONE_SIMULATOR == 1 {
            return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!)
        } else {
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        }
    }

    private static func getStoredDictionary() -> NSMutableDictionary {
        // TODO: エラーハンドリング
        return NSMutableDictionary(contentsOf: applicationSupportDir())!
    }

    static func getIsBackup(target: BackupTargetType) -> Bool? {
        let key = generateIsBackupKey(target: target)
        return NSDictionary(contentsOf: applicationSupportDir())?[key] as? Bool
    }

    static func setIsBackup(isBackup: Bool, target: BackupTargetType) {
        // TODO: エラーハンドリング
        let dic = getStoredDictionary()
        let key = generateIsBackupKey(target: target)
        dic[key] = isBackup
        try! dic.write(to: applicationSupportDir())
    }

    private static func generateIsBackupKey(target: BackupTargetType) -> String {
        return KEY_IS_BACKUP + "_" + target.toString()
    }
}
