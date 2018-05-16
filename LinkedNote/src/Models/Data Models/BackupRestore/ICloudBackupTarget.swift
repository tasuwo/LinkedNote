//
//  ICloudBackupTarget.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/12.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import Foundation
import RealmSwift

class ICloudBackupTarget: BackupRestoreStrategy {
    private let IMPORT_REALM_FILE_PATH = Realm.Configuration.defaultConfiguration.fileURL
    private let EXPORT_REALM_FILE_NAME = "linkedNote.realm"
    private let IMPORT_REALM_FILE_NAME = "default.realm"

    func backup() {
        do {
            let url = getExportRealmUrl()

            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }

            let realm = try! Realm()
            try realm.writeCopy(toFile: url)
        } catch {
            fatalError("\(error)")
        }
    }

    func restore() throws {
        let oldUrl = getExportRealmUrl()

        if !FileManager.default.fileExists(atPath: oldUrl.path) {
            throw NSError(domain: "ファイルが存在しません", code: -1, userInfo: nil)
        }

        do {
            _ = try FileManager.default.replaceItemAt(IMPORT_REALM_FILE_PATH!, withItemAt: oldUrl)
        } catch {
            fatalError("\(error)")
        }
    }

    // TODO: Check accessable to cloud storages
    private func getExportRealmUrl() -> URL {
        return FileManager.default
            .url(forUbiquityContainerIdentifier: nil)!
            .appendingPathComponent("Documents")
            .appendingPathComponent(EXPORT_REALM_FILE_NAME)
    }

    func isAvailable() -> Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            return true
        } else {
            return false
        }
    }
}
