//
//  DataModelError.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

enum DataModelError: Error {
    case IntegrityConstraintViolation
    case PrimaryKeyViolation
    case NecessaryDataDoesNotExist(_: String)
    case InvalidParameter(_: String)
}
