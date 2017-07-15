//
//  ArticleViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    var provider: ArticleViewProvider
    var singleTapRecognizer: UITapGestureRecognizer!
    var defaultFrameSize: CGRect!
    let article: Article
    let calculator: FrameCalculator
    let alertPresenter: AlertPresenter

    init(provider: ArticleViewProvider, article: Article, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.provider = provider
        self.article = article
        self.calculator = calculator
        self.alertPresenter = alertPresenter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.defaultFrameSize = self.calculator.calcFrameOnNavVar(by: self)

        // Initialize a view
        self.provider.view.frame = self.defaultFrameSize
        self.provider.setSplitBarDelegate(delegate: self)
        self.provider.noteView.delegate = self
        if let note = self.article.note {
            self.provider.noteView.text = note.body
        } else {
            self.provider.noteView.text = "ノートがまだ作成されていません"
        }

        // Recognize the touch to out of text field
        self.singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap))
        self.singleTapRecognizer.delegate = self
        self.provider.view.addGestureRecognizer(self.singleTapRecognizer)
        self.provider.splitBar.addGestureRecognizer(self.singleTapRecognizer)

        // Load web view
        // TODO: 進捗バーをつけたい
        if let url = URL(string: self.article.url) {
            self.provider.webView.loadRequest(URLRequest(url: url))
        }
        self.view.addSubview(self.provider.view)

        self.navigationItem.title = self.article.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_: Bool) {
        self.navigationController!.tabBarController!.tabBar.isHidden = true
    }

    // viewWillAppear で追加を行うと、画面遷移内にメソッドがトリガーされておかしな挙動になるので、
    // 読み込んでから追加する
    override func viewDidAppear(_: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillBeShown(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillBeHidden(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_: Bool) {
        self.navigationController!.tabBarController!.tabBar.isHidden = false

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        if self.provider.webView.isLoading {
            self.provider.webView.stopLoading()
        }
    }
}

// Keyboard 表示/非表示時のレイアウト調整
extension ArticleViewController {
    func keyboardWillBeShown(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else {
            return
        }
        let convertedKeyboardFrame = self.provider.view.convert(keyboardFrame, from: nil)

        // TODO: webView の上側が少し隠れてしまう
        //       auto layout を使用していると動的に view の frame を削除できないらしい。
        //       どうするか...
        //       より強い制約を追加すればなんとかなるかもしれない
        let newFrame = CGRect(
            x: self.defaultFrameSize!.origin.x,
            y: self.defaultFrameSize!.origin.y - convertedKeyboardFrame.height,
            width: self.defaultFrameSize!.size.width,
            height: self.defaultFrameSize!.size.height)
        self.provider.view.frame = newFrame
        self.provider.splitBarBottomConstraint.constant = 100

        UIView.animate(withDuration: animationDuration, animations: {
            self.provider.view.layoutIfNeeded()
        }, completion: { _ in })

        self.navigationController?.navigationBar.isHidden = true
        UIView.animate(withDuration: animationDuration, animations: {
            self.navigationController?.navigationBar.layer.layoutIfNeeded()
        }, completion: { _ in })
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else {
            return
        }

        self.provider.view.frame = self.defaultFrameSize!
        UIView.animate(withDuration: animationDuration, animations: {
            self.provider.view.layoutIfNeeded()
        }, completion: { _ in })

        self.navigationController?.navigationBar.isHidden = false
        UIView.animate(withDuration: animationDuration, animations: {
            self.navigationController?.navigationBar.layer.layoutIfNeeded()
        }, completion: { _ in })
    }
}

// split view のレイアウトを調整する
extension ArticleViewController: SplitBarDelegate {
    func dragging(sender _: Any, touch: UITouch) {
        let splitBarPosY: CGFloat = self.provider.splitBar.frame.minY
        let touchedPosY: CGFloat = touch.location(in: self.provider.view).y

        let nextYPos = self.provider.splitBarBottomConstraint.constant + splitBarPosY - touchedPosY

        if nextYPos > 80 {
            if nextYPos > self.provider.view.frame.maxY - 80 {
                self.provider.splitBarBottomConstraint.constant = self.provider.view.frame.maxY - 90
            } else {
                self.provider.splitBarBottomConstraint.constant = nextYPos
            }
        } else {
            self.provider.splitBarBottomConstraint.constant = 90
        }
    }
}

// articleView/SplitBar へのシングルタップを検知する
// キーボード表示を解除するために responder を resign する
extension ArticleViewController: UIGestureRecognizerDelegate {
    func onSingleTap(recognizer _: UIGestureRecognizer) {
        self.provider.noteView.resignFirstResponder()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer {
            return self.provider.noteView.isFirstResponder
        }
        return true
    }
}

extension ArticleViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else {
            self.alertPresenter.error("不明なエラー: テキスト情報の取得に失敗しました", on: self)
            return
        }
        didEditNoteBody(text)
    }

    func didEditNoteBody(_ body: String) {
        if let note = self.article.note {
            try! Note.update(note: note, body: body)
        } else {
            self.provider.noteView.text = ""
            self.alertPresenter.error("ノートの保存に失敗しました。ノートの作成に失敗している可能性があります", on: self)
        }
    }
}
