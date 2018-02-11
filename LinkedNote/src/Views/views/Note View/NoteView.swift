//
//  NoteView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import WebKit

protocol NoteViewProvider {
    var view: UIView { get }
    var notePlainTextView: UITextView { get }
    var noteMarkdownView: WKWebView { get }
    var tagCollectionView: UICollectionView { get }
    var segmentedControl: UISegmentedControl { get }
    func setNoteViewDelegate(_: NoteViewDelegate)
}

protocol NoteViewDelegate {
    func didPressEditButton()
    func didPressViewArticleButton()
    func didPressSegmentedControl(with index: Int)
}

class NoteView: UIView {
    var delegate: NoteViewDelegate?
    @IBOutlet var view_: UIView!
    @IBOutlet var notePlainTextView_: UITextView!
    @IBOutlet var noteMarkdownView_: WKWebView!
    @IBOutlet var tagCollectionView_: UICollectionView!
    @IBOutlet var segmentedControl_: UISegmentedControl!

    @IBAction func didPressEditButton(_: Any) {
        self.delegate?.didPressEditButton()
    }

    @IBAction func didPressViewArticleButton(_: Any) {
        self.delegate?.didPressViewArticleButton()
    }

    @IBAction func didPressSegmenttedControl(_ sender: UISegmentedControl) {
        self.delegate?.didPressSegmentedControl(with: sender.selectedSegmentIndex)
    }

    init() {
        super.init(frame: CGRect.zero)

        Bundle.main.loadNibNamed("Note", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)

        tagCollectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
        tagCollectionView.backgroundColor = .white
        tagCollectionView.isScrollEnabled = true
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteView: NoteViewProvider {
    var view: UIView {
        return self.view_
    }

    var notePlainTextView: UITextView {
        return self.notePlainTextView_
    }

    var noteMarkdownView: WKWebView {
        return self.noteMarkdownView_
    }

    var tagCollectionView: UICollectionView {
        return self.tagCollectionView_
    }

    var segmentedControl: UISegmentedControl {
        return self.segmentedControl_
    }

    func setNoteViewDelegate(_ delegate: NoteViewDelegate) {
        self.delegate = delegate
    }
}
