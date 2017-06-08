//
//  ArticleViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {
    var articleView: ArticleView!
    var singleTapRecognizer: UITapGestureRecognizer!
    var defaultFrameSize: CGRect!
    let article: Article
    let calculator: FrameCalculator
    
    init(article: Article, calculator: FrameCalculator) {
        self.article = article
        self.calculator = calculator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultFrameSize = self.calculator.calcFrameOnNavVar(by: self)
        
        // Initialize a view
        self.articleView = ArticleView(frame: self.defaultFrameSize)
        self.articleView.splitBarDelegate = self
        self.articleView.webView.delegate = self
        if let note = self.article.note {
            self.articleView.noteView.text = note.body
        } else {
            self.articleView.noteView.text = ""
            AlertCreater.error("ノートの作成に失敗しました。記事に対応する Api, ApiAccount が正常に保存されていない可能性があります。", viewController: self)
        }
        
        // Recognize the touch to out of text field
        self.singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap))
        self.singleTapRecognizer.delegate = self
        self.articleView.addGestureRecognizer(self.singleTapRecognizer)
        self.articleView.splitBar.addGestureRecognizer(self.singleTapRecognizer)
        
        // Load web view
        if let url = URL(string: self.article.url) {
            self.articleView.webView.loadRequest(URLRequest(url: url))
        }
        
        // Run animation while loading web view
        let backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = .white
        self.view.addSubview(backgroundView)
        let progressHUD = ProgressHUD(text: "Loading")
        self.view.addSubview(progressHUD)
        
        self.navigationItem.title = self.article.title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController!.tabBarController!.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillBeShown(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillBeHidden(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController!.tabBarController!.tabBar.isHidden = false
        // TODO: Save text dynamically
        if let note = self.article.note,
            let text = self.articleView.noteView.text {
            Note.update(note: note, body: text)
        } else {
            AlertCreater.error("ノートの保存に失敗しました。ノートが存在していません。", viewController: self)
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        if self.articleView.webView.isLoading {
            self.articleView.webView.stopLoading()
        }
    }
}

extension ArticleViewController {
    func keyboardWillBeShown(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            let convertedKeyboardFrame = self.articleView.convert(keyboardFrame, from: nil)
            
            // TODO: webView の上側が少し隠れてしまう
            //       auto layout を使用していると動的に view の frame を削除できないらしい。
            //       どうするか...
            //       より強い制約を追加すればなんとかなるかもしれない
            let newFrame = CGRect(
                x: self.defaultFrameSize!.origin.x,
                y: self.defaultFrameSize!.origin.y - convertedKeyboardFrame.height,
                width: self.defaultFrameSize!.size.width,
                height: self.defaultFrameSize!.size.height)
            self.articleView.frame = newFrame
            self.articleView.splitBarBottomConstraint.constant = 100
            UIView.animate(withDuration: animationDuration, animations: {
                self.articleView.layoutIfNeeded()
            }, completion: { finished in })
            
            // 編集中は navigation bar を隠す
            self.navigationController!.navigationBar.isHidden = true
            UIView.animate(withDuration: animationDuration, animations: {
                self.navigationController!.navigationBar.layer.layoutIfNeeded()
            }, completion: { finished in })
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
            self.articleView.frame = self.defaultFrameSize!
            UIView.animate(withDuration: animationDuration, animations: {
                self.articleView.layoutIfNeeded()
            }, completion: { finished in })
            
            self.navigationController!.navigationBar.isHidden = false
            UIView.animate(withDuration: animationDuration, animations: {
                self.navigationController!.navigationBar.layer.layoutIfNeeded()
            }, completion: { finished in })
        }
    }
}

extension ArticleViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if !webView.isLoading {
            self.view.addSubview(self.articleView)
        }
    }
}

extension ArticleViewController: SplitBarDelegate {
    func dragging(sender: Any, touch: UITouch) {
        let splitBarPosY: CGFloat = self.articleView.splitBar.frame.minY
        let touchedPosY: CGFloat = touch.location(in: self.articleView).y
        
        let nextYPos = self.articleView.splitBarBottomConstraint.constant + splitBarPosY - touchedPosY
        
        if nextYPos > 80 {
            if nextYPos > self.articleView.frame.maxY - 80 {
                self.articleView.splitBarBottomConstraint.constant = self.articleView.frame.maxY - 90
            } else {
                self.articleView.splitBarBottomConstraint.constant = nextYPos
            }
        } else {
            self.articleView.splitBarBottomConstraint.constant = 90
        }
    }
}

extension ArticleViewController: UIGestureRecognizerDelegate {
    func onSingleTap(recognizer: UIGestureRecognizer) {
        self.articleView.noteView.resignFirstResponder()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer {
            if self.articleView.noteView.isFirstResponder {
                return true
            } else {
                return false
            }
        }
        return true
    }
}
