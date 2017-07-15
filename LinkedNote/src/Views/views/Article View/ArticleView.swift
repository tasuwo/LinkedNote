//
//  ArticleView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol ArticleViewProvider {
    var view: UIView { get }
    var webView: UIWebView { get }
    var noteView: UITextView { get }
    var splitBar: UIButton { get }
    var splitBarBottomConstraint: NSLayoutConstraint { get }
    func setSplitBarDelegate(delegate: SplitBarDelegate)
}

protocol SplitBarDelegate {
    func dragging(sender: Any, touch: UITouch)
}

class ArticleView: UIView {
    var splitBarDelegate: SplitBarDelegate?
    @IBOutlet var view_: UIView!
    @IBOutlet weak var webView_: UIWebView!
    @IBOutlet weak var noteView_: UITextView!
    @IBOutlet weak var splitBar_: UIButton!
    @IBOutlet weak var splitBarBottomConstraint_: NSLayoutConstraint!

    @IBAction func touchDragInsideSplitBar(_ sender: Any, event: UIEvent) {
        if let touch = event.allTouches?.first {
            self.splitBarDelegate?.dragging(sender: sender, touch: touch)
        }
    }

    @IBAction func touchDragOutsideSplitBar(_ sender: Any, event: UIEvent) {
        if let touch = event.allTouches?.first {
            self.splitBarDelegate?.dragging(sender: sender, touch: touch)
        }
    }

    init() {
        super.init(frame: CGRect.zero)
        Bundle.main.loadNibNamed("Article", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleView: ArticleViewProvider {
    var view: UIView {
        return self.view_
    }

    var webView: UIWebView {
        return self.webView_
    }

    var noteView: UITextView {
        return self.noteView_
    }

    var splitBar: UIButton {
        return self.splitBar_
    }

    var splitBarBottomConstraint: NSLayoutConstraint {
        return self.splitBarBottomConstraint_
    }

    func setSplitBarDelegate(delegate: SplitBarDelegate) {
        self.splitBarDelegate = delegate
    }
}
