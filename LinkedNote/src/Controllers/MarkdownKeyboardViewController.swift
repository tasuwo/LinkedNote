//
//  MarkdownKeyboardViewController.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/11.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol MarkdownKeyboardViewControllerDelegate {
    func didEditTextView(textView: UITextView)
}

class MarkdownKeyboardViewController: UIViewController {
    let textView: UITextView!
    let delegate: MarkdownKeyboardViewControllerDelegate!
    let presenter: MarkdownKeyboardPresenter!

    init(textView: UITextView, delegate: MarkdownKeyboardViewControllerDelegate) {
        self.textView = textView
        self.delegate = delegate
        self.presenter = MarkdownKeyboardPresenter()
        super.init(nibName: nil, bundle: nil)
        self.textView.delegate = self

        let accessoryView = MarkdownKeyboardAccessory(textView: textView)
        accessoryView.delegate = self
        accessoryView.lineUpButtons(keyKinds: self.presenter.lineOfKeys)
        textView.inputAccessoryView = accessoryView
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MarkdownKeyboardViewController: MarkdownKeyboardDelegate {
    func didPressMarkdownKeyboardKey(kind: MarkdownKeyboardKeyKind) {
        let req = self.presenter.publishKeyInputRequest(kind: kind)
        self.textView.insertText(req.inputString)
        changeCursorPosition(to: req.cursorPosition)
    }

    private func changeCursorPosition(to offset: Int) {
        if let selectedRange = self.textView.selectedTextRange {
            if let newPosition = self.textView.position(from: selectedRange.start, offset: offset) {
                self.textView.selectedTextRange = self.textView.textRange(from: newPosition, to: newPosition)
            }
        }
    }
}

extension MarkdownKeyboardViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldChangeTextIn _: NSRange, replacementText string: String) -> Bool {
        if string == "\n" {
            print("returned")
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        self.delegate.didEditTextView(textView: textView)
    }
}
