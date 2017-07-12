//
//  AssertNotNilAndUnwrap.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/07/12.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import XCTest

struct UnexpectedNilError: Error {}

func AssertNotNilAndUnwrap<T>(_ variable: T?, message: String = "Unexpected nil variable", file: StaticString = #file, line: UInt = #line) throws -> T {
    guard let variable = variable else {
        XCTFail(message, file: file, line: line)
        throw UnexpectedNilError()
    }
    return variable
}
