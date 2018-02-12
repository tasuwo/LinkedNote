//
//  MarkdownKeybardAccessoryButton.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/11.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

class MarkdownKeyboardKey: UIButton, UIInputViewAudioFeedback {
    var enableInputClicksWhenVisible: Bool {
        return true
    }

    private(set) var kind: MarkdownKeyboardKeyKind!

    convenience init(kind: MarkdownKeyboardKeyKind, titleText text: String) {
        self.init(frame: CGRect.zero)
        self.kind = kind
        self.setTitle(text, for: .normal)
    }

    convenience init(kind: MarkdownKeyboardKeyKind, keyImage image: UIImage) {
        self.init(frame: CGRect.zero)
        self.kind = kind
        self.setImage(image, for: .normal)
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTitleColor(UIColor.black, for: UIControlState.normal)

        self.layer.cornerRadius = 4.0
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func playClick() {
        UIDevice.current.playInputClick()
    }

    func setUpColors(appearance: UIKeyboardAppearance) {
        self.backgroundColor = MarkdownKeyboardColor.ofButton(at: appearance)
        self.layer.shadowColor = MarkdownKeyboardColor.ofButtonShadow(at: appearance).cgColor
    }
}
