//
//  TagMenuView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol TagMenuViewProvider {
    var view: UIView { get }
    var baseView: UIView { get }
    var newTagNameField: UITextField { get }
    var tagPicker: UIPickerView { get }
    var tagCollectionView: UICollectionView { get }
    var blurEffectView: UIVisualEffectView { get }
    var note: Note? { get }

    func setDelegate(_: TagMenuViewDelegate)
    func setNote(_: Note)
}

protocol TagMenuViewDelegate {
    func didPressCloseButton()
    func didPressSelectExistTagButton(_ index: Int)
    func didPressCreateNewTagButton(_ newTagName: String)
}

class TagMenuView: UIView {
    var delegate: TagMenuViewDelegate?
    @IBOutlet weak var newTagNameField_: UITextField!
    @IBOutlet var view_: UIView!
    @IBOutlet weak var tagPicker_: UIPickerView!
    var note_: Note?
    @IBOutlet weak var tagCollectionView_: UICollectionView!
    @IBOutlet weak var newTagButton_: UIButton!

    @IBAction func didPressCloseButton(_: Any) {
        self.delegate?.didPressCloseButton()
    }

    @IBAction func didPressSelectTagButton(_: Any) {
        let i = self.tagPicker_.selectedRow(inComponent: 0)
        self.delegate?.didPressSelectExistTagButton(i)
    }

    @IBAction func didPressCreateNewTagButton(_: Any) {
        let newTagName = self.newTagNameField_.text ?? ""
        self.delegate?.didPressCreateNewTagButton(newTagName)
    }

    private(set) var blurEffectView_: UIVisualEffectView!

    init() {
        super.init(frame: CGRect.zero)

        // only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clear

            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            self.blurEffectView_ = UIVisualEffectView(effect: blurEffect)
            // always fill the view
            self.blurEffectView_.frame = CGRect.zero
            self.blurEffectView_.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            self.addSubview(self.blurEffectView_)
        } else {
            self.backgroundColor = UIColor.black
        }

        Bundle.main.loadNibNamed("TagMenu", owner: self, options: nil)
        view_.frame = CGRect.zero

        tagCollectionView_.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
        tagCollectionView_.backgroundColor = UIColor.clear
        tagCollectionView_.isScrollEnabled = true

        self.insertSubview(view_, at: 1)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TagMenuView: TagMenuViewProvider {
    var view: UIView {
        return self
    }

    var baseView: UIView {
        return self.view_
    }

    var newTagNameField: UITextField {
        return self.newTagNameField_
    }

    var tagPicker: UIPickerView {
        return self.tagPicker_
    }

    var tagCollectionView: UICollectionView {
        return self.tagCollectionView_
    }

    var blurEffectView: UIVisualEffectView {
        return self.blurEffectView_
    }

    var note: Note? {
        return self.note_
    }

    func setDelegate(_ delegate: TagMenuViewDelegate) {
        self.delegate = delegate
    }

    func setNote(_ note: Note) {
        self.note_ = note
    }
}
