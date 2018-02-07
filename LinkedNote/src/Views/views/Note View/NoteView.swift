//
//  NoteView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol NoteViewProvider {
    var view: UIView { get }
    var noteView: UITextView { get }
    var tagCollectionView: UICollectionView { get }
    func setNoteViewDelegate(_: NoteViewDelegate)
}

protocol NoteViewDelegate {
    func didPressEditButton()
    func didPressViewArticleButton()
}

class NoteView: UIView {
    var delegate: NoteViewDelegate?
    @IBOutlet var view_: UIView!
    @IBOutlet var noteView_: UITextView!
    @IBOutlet var tagCollectionView_: UICollectionView!
    @IBAction func didPressEditButton(_: Any) {
        self.delegate?.didPressEditButton()
    }

    @IBAction func didPressViewArticleButton(_: Any) {
        self.delegate?.didPressViewArticleButton()
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

    var noteView: UITextView {
        return self.noteView_
    }

    var tagCollectionView: UICollectionView {
        return self.tagCollectionView_
    }

    func setNoteViewDelegate(_ delegate: NoteViewDelegate) {
        self.delegate = delegate
    }
}
