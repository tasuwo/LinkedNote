//
//  BackupTarget.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/03/09.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

public enum BackupTargetType: Int {
    case iCloud
    case DropBox
    case GoogleDrive

    func toString() -> String {
        switch self {
        case .iCloud: return "iCloud"
        case .DropBox: return "DropBox"
        case .GoogleDrive: return "GoogleDrive"
        }
    }

    func getStrategy() -> BackupRestoreStrategy? {
        switch self {
        case .iCloud: return ICloudBackupTarget()
        // TODO: Implement
        case .DropBox: return nil
        case .GoogleDrive: return nil
        }
    }

    static let count: Int = {
        var max: Int = 0
        while let _ = BackupTargetType(rawValue: max) { max += 1 }
        return max
    }()
}
