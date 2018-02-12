//
//  MarkdownKeysPresenter.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/12.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

class MarkdownKeyInputRequest {
    let inputString: String
    let cursorPosition: Int
    init(_ input: String, _ pos: Int) {
        self.inputString = input
        self.cursorPosition = pos
    }
}

class MarkdownKeyboardPresenter {
    var lineOfKeys: [MarkdownKeyboardKeyKind] = [
        .PlainList,
        .NumericList,
        .Emphasis,
        .Italic,
        .Tab,
        .ThematicBreaks,
        .Heading,
        .CodeBlock,
        .BlockQuotes,
        .Image,
        .Link,
    ]

    func publishKeyInputRequest(kind: MarkdownKeyboardKeyKind) -> MarkdownKeyInputRequest {
        switch kind {
        case .PlainList:
            /*
             * - hoge
             * - fuga
             * ...
             */
            return MarkdownKeyInputRequest("- ", 0)
        case .NumericList:
            /*
             * 1. hoge
             * 2. fuga
             * ...
             */
            return MarkdownKeyInputRequest("1. ", 0)
        case .Emphasis:
            /*
             * **hoge**
             */
            return MarkdownKeyInputRequest("****", -2)
        case .Italic:
            /*
             * *hoge*
             */
            return MarkdownKeyInputRequest("**", -1)
        case .Tab:
            /*
             * [    ]hoge
             */
            return MarkdownKeyInputRequest("    ", 0)
        case .ThematicBreaks:
            /*
             * ---
             */
            return MarkdownKeyInputRequest("---\n", 0)
        case .Heading:
            /*
             * # hoge
             */
            return MarkdownKeyInputRequest("#", 0)
        case .CodeBlock:
            /*
             * ```
             * hoge
             * fuga
             * ```
             */
            return MarkdownKeyInputRequest("```\n\n```", -4)
        case .BlockQuotes:
            /*
             * > hoge
             * > fuga
             * ...
             */
            return MarkdownKeyInputRequest("> ", 0)
        case .Link:
            /*
             * ()[]
             */
            return MarkdownKeyInputRequest("()[]", -3)
        case .Image:
            /*
             * !()[]
             */
            return MarkdownKeyInputRequest("!()[]", -3)
        }
    }
}
