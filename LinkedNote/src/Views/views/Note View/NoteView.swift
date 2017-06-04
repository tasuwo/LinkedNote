//
//  NoteView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol NoteViewDelegate {
    func didPressEditButton()
}

class NoteView: UIView {
    var delegate: NoteViewDelegate?
    @IBOutlet var view_: UIView!
    @IBOutlet weak var noteView: UITextView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBAction func didPressEditButton(_ sender: Any) {
        self.delegate?.didPressEditButton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        Bundle.main.loadNibNamed("Note", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
        
        tagCollectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
        tagCollectionView.backgroundColor = .white
        tagCollectionView.isScrollEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}