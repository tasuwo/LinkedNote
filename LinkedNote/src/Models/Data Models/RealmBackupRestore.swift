//
//  RealmBackupRestore.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/12.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmBackupRestoreTarget {
    case iCoud
    case googleDrive
    case dropBox
}

class RealmBackupRestore {
    private let IMPORT_REALM_FILE_PATH = Realm.Configuration.defaultConfiguration.fileURL
    private let EXPORT_REALM_FILE_NAME = "linkedNote.realm"
    private let IMPORT_REALM_FILE_NAME = "default.realm"

    func backup(to target: RealmBackupRestoreTarget) {
        do {
            let realm = try! Realm()
            try realm.writeCopy(toFile: getExportRealmPath(by: target))
        } catch {
            fatalError()
        }
    }

    func restore(from target: RealmBackupRestoreTarget) {
        let oldPath = getExportRealmPath(by: target)
        do {
            _ = try FileManager.default.replaceItemAt(IMPORT_REALM_FILE_PATH!, withItemAt: oldPath)
        } catch {
            fatalError()
        }
    }

    // TODO: Check accessable to cloud storages
    private func getExportRealmPath(by target: RealmBackupRestoreTarget) -> URL {
        switch target {
        case .iCoud:
            return FileManager.default
                .url(forUbiquityContainerIdentifier: nil)!
                .appendingPathComponent("Documents")
                .appendingPathComponent(EXPORT_REALM_FILE_NAME)
        case .googleDrive:
            fatalError("Not implemented yet")
        case .dropBox:
            fatalError("Not implemented yet")
        }
    }

    func isICloudContainerAvailable() -> Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }
}
