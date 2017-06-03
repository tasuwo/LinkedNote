//
//  ArticleViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    var info: ArticleInfo? = nil
    var note: Note? = nil
    var view_: ArticleView!
    var singleTapRecognizer: UITapGestureRecognizer?
    var defaultFrameSize: CGRect?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fix frame size
        let viewBounds = self.view.bounds;
        let topBarOffSet = self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        self.defaultFrameSize = CGRect(x: 0, y: 0, width: viewBounds.width, height: viewBounds.height - topBarOffSet)
        self.view.frame = self.defaultFrameSize!

        view_ = ArticleView(frame: self.view.frame)
        view_.splitBarDelegate = self
        view_.webView?.delegate = self
        if let n = self.note {
            view_.noteView?.text = n.body
        } else {
            view_.noteView?.text = ""
            AlertCreater.error("ノートの作成に失敗しました。記事に対応する Api, ApiAccount が正常に保存されていない可能性があります。", viewController: self)
        }
        
        // Load web view
        if let urlStr = self.info?.url,
           let url = URL(string: urlStr) {
            view_.webView.loadRequest(URLRequest(url: url))
        }
        
        // Recognize the touch to out of text field
        self.singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap))
        self.singleTapRecognizer?.delegate = self
        self.view_.addGestureRecognizer(self.singleTapRecognizer!)
        self.view_.splitBar.addGestureRecognizer(self.singleTapRecognizer!)

        // Run animation while loading web view
        let backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = .white
        self.view.addSubview(backgroundView)
        let progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        
        self.navigationItem.title = info?.title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.tabBarController!.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.tabBarController!.tabBar.isHidden = false
        // TODO: Save text dynamically
        if let note = self.note,
           let text = self.view_.noteView.text {
            Note.update(note: note, body: text)
        } else {
            AlertCreater.error("ノートの保存に失敗しました。ノートが存在していません。", viewController: self)
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if self.view_.webView.isLoading {
            self.view_.webView.stopLoading()
        }
    }
}

extension ArticleViewController {
    func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                let convertedKeyboardFrame = self.view_.convert(keyboardFrame, from: nil)
                
                // TODO: webView の上側が少し隠れてしまう
                //       auto layout を使用していると動的に view の frame を削除できないらしい。
                //       どうするか...
                //       より強い制約を追加すればなんとかなるかもしれない
                let newFrame = CGRect(
                    x: self.defaultFrameSize!.origin.x,
                    y: self.defaultFrameSize!.origin.y - convertedKeyboardFrame.height,
                    width: self.defaultFrameSize!.size.width,
                    height: self.defaultFrameSize!.size.height)
                self.view_.frame = newFrame
                self.view_.splitBarBottomConstraint.constant = 100
                UIView.animate(withDuration: animationDuration, animations: {
                    self.view_.layoutIfNeeded()
                }, completion: { finished in })
                
                // 編集中は navigation bar を隠す
                self.navigationController!.navigationBar.isHidden = true
                UIView.animate(withDuration: animationDuration, animations: {
                    self.navigationController!.navigationBar.layer.layoutIfNeeded()
                }, completion: { finished in })
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {

                self.view_.frame = self.defaultFrameSize!
                UIView.animate(withDuration: animationDuration, animations: {
                    self.view_.layoutIfNeeded()
                }, completion: { finished in })
                
                self.navigationController!.navigationBar.isHidden = false
                UIView.animate(withDuration: animationDuration, animations: {
                    self.navigationController!.navigationBar.layer.layoutIfNeeded()
                }, completion: { finished in })
            }
        }
    }
}

extension ArticleViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !webView.isLoading {
            self.view.addSubview(self.view_)
        }
    }
}

extension ArticleViewController: SplitBarDelegate {
    func dragging(sender: Any, touch: UITouch) {
        let splitBarPosY: CGFloat = self.view_!.splitBar.frame.minY
        let touchedPosY: CGFloat = touch.location(in: self.view_).y
        
        let nextYPos = self.view_.splitBarBottomConstraint.constant + splitBarPosY - touchedPosY

        if nextYPos > 80 {
            if nextYPos > self.view_.frame.maxY - 80 {
                self.view_.splitBarBottomConstraint.constant = self.view_.frame.maxY - 90
            } else {
                self.view_.splitBarBottomConstraint.constant = nextYPos
            }
        } else {
            self.view_.splitBarBottomConstraint.constant = 90
        }
    }
}

extension ArticleViewController: UIGestureRecognizerDelegate {
    func onSingleTap(recognizer: UIGestureRecognizer) {
        self.view_.noteView.resignFirstResponder()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer {
            if self.view_.noteView.isFirstResponder {
                return true
            } else {
                return false
            }
        }
        return true
    }
}
