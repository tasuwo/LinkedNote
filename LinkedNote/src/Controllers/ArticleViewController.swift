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
    var keyboardAccessoryVC: MarkdownKeyboardViewController!

    var isKeyboardHidden = true
    var lastPoint: CGFloat = 0
    var isNavigationBarShown = true

    let noteRepository: Repository<Note>

    init(provider: ArticleViewProvider, article: Article, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.provider = provider
        self.article = article
        self.calculator = calculator
        self.alertPresenter = alertPresenter
        // TODO: Factory pattern
        self.noteRepository = Repository<Note>()
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
        if let note = self.article.note {
            self.provider.noteView.text = note.body
        } else {
            self.provider.noteView.text = "ノートがまだ作成されていません"
        }

        // Add markdown keyboard accessory to note view
        self.keyboardAccessoryVC = MarkdownKeyboardViewController(textView: self.provider.noteView, delegate: self)

        // Recognize the touch to out of text field
        self.singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap))
        self.singleTapRecognizer.delegate = self
        self.provider.view.addGestureRecognizer(self.singleTapRecognizer)
        self.provider.splitBar.addGestureRecognizer(self.singleTapRecognizer)

        // Load web view
        if let url = URL(string: self.article.url) {
            self.provider.webView.load(URLRequest(url: url))
        }
        self.provider.webView.scrollView.delegate = self
        self.view.addSubview(self.provider.view)

        // Web view's progress bar
        self.provider.progressBar.frame = CGRect(
            x: 0,
            y: self.navigationController!.navigationBar.frame.size.height - 2,
            width: self.view.frame.size.width,
            height: 10
        )
        self.navigationController?.navigationBar.addSubview(self.provider.progressBar)
        // Observers to update display of the progress
        self.provider.webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        self.provider.webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        self.navigationItem.title = self.article.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    deinit {
        self.provider.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.provider.webView.removeObserver(self, forKeyPath: "loading")
    }

    func hideNavigationBar() {
        let newFrame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: self.defaultFrameSize.height + self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height)
        self.provider.view.frame = newFrame
        // TODO: 0.2 秒が固定値なので、animated のデフォルト遷移時間にしたい (nav bar の遷移時間とあわせたい)
        UIView.animate(withDuration: 0.2, animations: {
            self.provider.view.layoutIfNeeded()
        }, completion: { _ in })

        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    func showNavigationBar() {
        let newFrame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: self.defaultFrameSize.height)
        self.provider.view.frame = newFrame
        // TODO: 0.2 秒が固定値なので、animated のデフォルト遷移時間にしたい (nav bar の遷移時間とあわせたい)
        UIView.animate(withDuration: 0.2, animations: {
            self.provider.view.layoutIfNeeded()
        }, completion: { _ in })

        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

// Progress バー描画
extension ArticleViewController {
    override func observeValue(forKeyPath keyPath: String?, of _: Any?, change _: [NSKeyValueChangeKey: Any]?, context _: UnsafeMutableRawPointer?) {
        guard let path = keyPath else {
            return
        }

        switch path {
        // Progress state was updated
        case "estimatedProgress":
            self.provider.progressBar.setProgress(
                Float(self.provider.webView.estimatedProgress),
                animated: true
            )
        // Finish loading or not
        case "loading":
            UIApplication.shared.isNetworkActivityIndicatorVisible = self.provider.webView.isLoading
            self.provider.progressBar.setProgress(
                self.provider.webView.isLoading ? 0.1 : 0.0,
                animated: false
            )
        default:
            return
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

        if isNavigationBarShown {
            hideNavigationBar()
        }

        let newFrame = CGRect(
            x: 0,
            y: 0,
            width: self.view.bounds.width,
            height: self.defaultFrameSize.height + self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height - convertedKeyboardFrame.height)
        self.provider.view.frame = newFrame
        self.provider.splitBarBottomConstraint.constant = 100

        UIView.animate(withDuration: animationDuration, animations: {
            self.provider.view.layoutIfNeeded()
        }, completion: { _ in })

        isKeyboardHidden = false
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else {
            return
        }

        showNavigationBar()

        self.provider.view.frame = self.defaultFrameSize!

        UIView.animate(withDuration: animationDuration, animations: {
            self.provider.view.layoutIfNeeded()
        }, completion: { _ in })

        isKeyboardHidden = true
    }
}

// split view のレイアウトを調整する
extension ArticleViewController: SplitBarDelegate {
    func dragging(sender _: Any, touch: UITouch) {
        let splitBarPosY: CGFloat = self.provider.splitBar.frame.minY
        let touchedPosY: CGFloat = touch.location(in: self.provider.view).y

        let nextYPos = self.provider.splitBarBottomConstraint.constant + splitBarPosY - touchedPosY

        if nextYPos > 60 {
            if nextYPos > self.provider.view.frame.maxY - 60 {
                self.provider.splitBarBottomConstraint.constant = self.provider.view.frame.maxY - 70
            } else {
                self.provider.splitBarBottomConstraint.constant = nextYPos
            }
        } else {
            self.provider.splitBarBottomConstraint.constant = 70
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

extension ArticleViewController: MarkdownKeyboardViewControllerDelegate {
    func didEditTextView(textView: UITextView) {
        guard let text = textView.text else {
            self.alertPresenter.error("不明なエラー: テキスト情報の取得に失敗しました", on: self)
            return
        }
        didEditNoteBody(text)
    }

    func didEditNoteBody(_ body: String) {
        if let note = self.article.note {
            try! noteRepository.update(note, body: body)
        } else {
            self.provider.noteView.text = ""
            self.alertPresenter.error("ノートの保存に失敗しました。ノートの作成に失敗している可能性があります", on: self)
        }
    }
}

extension ArticleViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset.y

        if isKeyboardHidden == false {
            return
        }

        if currentPoint < 50 {
            showNavigationBar()
        } else if lastPoint - currentPoint < 0 {
            hideNavigationBar()
        } else if lastPoint - currentPoint > 10 {
            showNavigationBar()
        }

        lastPoint = currentPoint
    }
}
