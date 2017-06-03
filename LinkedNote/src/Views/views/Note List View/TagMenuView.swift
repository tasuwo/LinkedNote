//
//  TagMenuView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol TagMenuViewDelegate {
    func didPressCloseButton()
    func didPressSelectExistTagButton(_ index: Int)
    func didPressCreateNewTagButton(_ newTagName: String)
}

class TagMenuView: UIView {
    var delegate: TagMenuViewDelegate?
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var newTagNameField: UITextField!
    @IBOutlet var view_: UIView!
    @IBOutlet weak var tagPicker: UIPickerView!
    var note: Note? = nil
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var newTagButton: UIButton!
    
    @IBAction func didPressCloseButton(_ sender: Any) {
        self.delegate?.didPressCloseButton()
    }
    @IBAction func didPressSelectTagButton(_ sender: Any) {
        let i = self.tagPicker.selectedRow(inComponent: 0)
        self.delegate?.didPressSelectExistTagButton(i)
    }
    @IBAction func didPressCreateNewTagButton(_ sender: Any) {
        let newTagName = self.newTagNameField.text ?? ""
        self.delegate?.didPressCreateNewTagButton(newTagName)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = frame
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.addSubview(blurEffectView)
        } else {
            self.backgroundColor = UIColor.black
        }
        
        Bundle.main.loadNibNamed("TagMenu", owner: self, options: nil)
        view_.frame = frame
        
        tagCollectionView.register(UINib(nibName: "TagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TagCollectionViewCell")
        tagCollectionView.backgroundColor = UIColor.clear
        tagCollectionView.isScrollEnabled = true
 
        self.insertSubview(view_, at: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
