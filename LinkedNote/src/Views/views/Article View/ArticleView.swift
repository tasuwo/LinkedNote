//
//  ArticleView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/30.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol SplitBarDelegate {
    func dragging(sender: Any, touch: UITouch)
}

class ArticleView: UIView {
    var splitBarDelegate: SplitBarDelegate?
    @IBOutlet var view_: UIView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var splitBar: UIButton!
    @IBOutlet weak var splitBarBottomConstraint: NSLayoutConstraint!

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

    override init(frame: CGRect) {
        super.init(frame: frame)

        Bundle.main.loadNibNamed("Article", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
