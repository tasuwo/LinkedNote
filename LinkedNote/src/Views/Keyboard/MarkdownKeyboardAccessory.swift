//
//  MarkdownKeyboardAccessory.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/11.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol MarkdownKeyboardDelegate {
    func didPressMarkdownKeyboardKey(kind: MarkdownKeyboardKeyKind)
}

class MarkdownKeyboardAccessory: UIView {
    var delegate: MarkdownKeyboardDelegate?
    var keybaordAppearance: UIKeyboardAppearance!

    let KEY_HEIGHT: CGFloat = 40
    let KEY_WIDTH: CGFloat = 40
    let KEY_LR_MARGIN: CGFloat = 5
    let KEY_TB_MARGIN: CGFloat = 5
    let KEYBOARD_HEIGHT: CGFloat = 50
    var KEYBOARD_WIDTH: CGFloat!

    var scrollView_: UIScrollView!
    var markdownCustomKeys: [MarkdownKeyboardKey] = []

    func didPressMarkdownKeyboardKey(_ sender: Any, event _: UIEvent) {
        guard let key = sender as? MarkdownKeyboardKey else {
            return
        }
        self.delegate?.didPressMarkdownKeyboardKey(kind: key.kind)
    }

    convenience init(textView: UITextView) {
        self.init(frame: CGRect.zero)

        self.KEYBOARD_WIDTH = textView.frame.width
        self.keybaordAppearance = textView.keyboardAppearance
        self.backgroundColor = MarkdownKeyboardColor.ofKeyboardBackground(at: self.keybaordAppearance)

        let keyboardFrame = CGRect(x: 0, y: 0, width: self.KEYBOARD_WIDTH, height: KEYBOARD_HEIGHT)

        self.frame = keyboardFrame

        scrollView_ = UIScrollView(frame: keyboardFrame)
        scrollView_.showsVerticalScrollIndicator = false
        scrollView_.showsHorizontalScrollIndicator = false
        scrollView_.backgroundColor = MarkdownKeyboardColor.ofKeyboardBackground(at: self.keybaordAppearance)
        addSubview(scrollView_)
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func lineUpButtons(keyKinds: [MarkdownKeyboardKeyKind]) {
        // Remove all keys if there are
        for key in self.markdownCustomKeys {
            key.removeFromSuperview()
        }
        self.markdownCustomKeys = []

        // Create keys and placing them
        var index: CGFloat = 0
        for kind in keyKinds {
            let button = MarkdownKeyboardKey(kind: kind, titleText: getKeyTitle(by: kind))
            button.addTarget(self, action: #selector(didPressMarkdownKeyboardKey(_:event:)), for: .touchUpInside)
            button.setUpColors(appearance: self.keybaordAppearance)
            button.frame = CGRect(
                x: KEY_LR_MARGIN + ((KEY_WIDTH + KEY_LR_MARGIN) * index),
                y: KEY_TB_MARGIN,
                width: KEY_WIDTH,
                height: KEY_HEIGHT
            )
            scrollView_.addSubview(button)
            self.markdownCustomKeys.append(button)

            index += 1
        }

        scrollView_.contentSize = CGSize(
            width: KEY_LR_MARGIN + (KEY_WIDTH + KEY_LR_MARGIN) * CGFloat(self.markdownCustomKeys.count),
            height: KEYBOARD_HEIGHT
        )
    }

    private func getKeyTitle(by kind: MarkdownKeyboardKeyKind) -> String {
        switch kind {
        case .PlainList:
            return "-"
        case .NumericList:
            return "1."
        case .Emphasis:
            return "****"
        case .Italic:
            return "I"
        case .Tab:
            return "Tab"
        case .ThematicBreaks:
            return "---"
        case .Heading:
            return "#"
        case .CodeBlock:
            return "```"
        case .BlockQuotes:
            return ">"
        case .Image:
            return "Img"
        case .Link:
            return "Link"
        }
    }
}
