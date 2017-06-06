//
//  TagEditableViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol DetectableTagMenuViewEvent {
    func didClose()
}

class TagEditableViewController: UIViewController {
    var delegate: DetectableTagMenuViewEvent?
    var tagMenuView: TagMenuView?
    var tagMenuPickerPresenter: TagPickerPresenter?
    var tagMenuCollectionPresenter: TagCollectionPresenter?
    var tagMenuViewDelegater: TagEditableViewDelegater?
    var tagMenuSingleTapRecognizer: UITapGestureRecognizer?
    var fullScrnFrame: CGRect?
    var isNewTagNameEditing: Bool = false
    
    func initializeTagEditView(note: Note) {
        tagMenuView = TagMenuView(frame: self.tabBarController!.view.frame)
        tagMenuView!.note = note
        
        tagMenuPickerPresenter = TagPickerPresenter()
        tagMenuPickerPresenter!.load()
        tagMenuView!.tagPicker.dataSource = tagMenuPickerPresenter!
        
        tagMenuCollectionPresenter = TagCollectionPresenter()
        tagMenuCollectionPresenter!.load(noteId: note.id)
        
        tagMenuView!.tagCollectionView.dataSource = tagMenuCollectionPresenter
        tagMenuView!.tagCollectionView.reloadData()
        
        self.tagMenuViewDelegater = TagEditableViewDelegater(self)
        tagMenuView!.tagPicker.delegate = self.tagMenuViewDelegater
        tagMenuView!.delegate = self.tagMenuViewDelegater
        tagMenuView!.tagCollectionView.delegate = self.tagMenuViewDelegater
        
        if let vc = self as? DetectableTagMenuViewEvent {
            self.tagMenuViewDelegater?.delegate = vc
        }
        
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.15
        transition.type = kCATransitionFade
        self.tabBarController?.view.layer.add(transition, forKey: kCATransition)
        
        self.tabBarController?.view.addSubview(tagMenuView!)
        
        self.fullScrnFrame = self.tagMenuView!.frame
    }
    
    func tagEditKeyboardWillBeShown(notification: NSNotification) {
        if let tagMenuView = self.tagMenuView,
            let tagNameField = tagMenuView.newTagNameField {
            if tagNameField.isFirstResponder == false { return }
        } else { return }

        if self.isNewTagNameEditing { return }
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue, let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                
                let convertedKeyboardFrame = self.tagMenuView?.convert(keyboardFrame, from: nil)
                UIView.animate(withDuration: animationDuration, animations: {
                    self.tagMenuView!.frame = self.tagMenuView!.frame.insetBy(dx: 0, dy: -1 * (convertedKeyboardFrame?.height)!)
                }, completion: { finished in })
            }
        }
        self.isNewTagNameEditing = true
    }
    
    func tagEditKeyboardWillBeHidden(notification: NSNotification) {
        if let tagMenuView = self.tagMenuView,
           let tagNameField = tagMenuView.newTagNameField {
            if tagNameField.isFirstResponder == false { return }
        } else { return }

        if let userInfo = notification.userInfo {
            if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                UIView.animate(withDuration: animationDuration, animations: {
                    self.tagMenuView!.frame = self.fullScrnFrame!
                }, completion: { finished in })
            }
        }
        self.isNewTagNameEditing = false
    }
}

class TagEditableViewDelegater: NSObject {
    var delegate: DetectableTagMenuViewEvent?
    var tagMenuView: TagMenuView?
    var tagCollectionPresenter: TagCollectionPresenter?
    var tagPickerPresenter: TagPickerPresenter?
    var targetViewController: TagEditableViewController?
    var singleTapRecognizer: UITapGestureRecognizer?
    
    init(_ viewController: TagEditableViewController) {
        super.init()
        self.tagMenuView = viewController.tagMenuView
        self.tagCollectionPresenter = viewController.tagMenuCollectionPresenter
        self.tagPickerPresenter = viewController.tagMenuPickerPresenter
        self.targetViewController = viewController
        self.delegate = viewController.delegate
        
        // Recognize the touch to out of text field
        self.singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap(recognizer:)))
        self.singleTapRecognizer!.delegate = self
        self.tagMenuView!.view_.addGestureRecognizer(self.singleTapRecognizer!)
    }
}

extension TagEditableViewDelegater:  UIGestureRecognizerDelegate {
    func onSingleTap(recognizer: UIGestureRecognizer) {
        self.tagMenuView?.newTagNameField.resignFirstResponder()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer {
            if (self.targetViewController?.tagMenuView?.newTagNameField.isFirstResponder)! {
                return true
            } else {
                return false
            }
        }
        return true
    }
}

extension TagEditableViewDelegater: TagMenuViewDelegate {
    func didPressCloseButton() {
        UIView.animate(withDuration: 0.2 as TimeInterval, animations: {
            self.tagMenuView?.alpha = 0
        }, completion: { finished in
            self.tagMenuView?.removeFromSuperview()
            self.delegate?.didClose()
        })
    }
    
    func didPressSelectExistTagButton(_ index: Int) {
        let selectedTag = tagPickerPresenter!.tags[index]
        let selectedNote = self.tagMenuView!.note!
        Tag.add(selectedTag, to: selectedNote)
        
        tagCollectionPresenter!.load(noteId: tagMenuView!.note!.id)
        tagMenuView?.tagCollectionView.reloadData()
    }
    
    func didPressCreateNewTagButton(_ newTagName: String) {
        let newTag = Tag(name: newTagName)
        Tag.add(newTag)
        
        let selectedNote = self.tagMenuView!.note!
        Tag.add(newTag, to: selectedNote)
        
        tagCollectionPresenter!.load(noteId: tagMenuView!.note!.id)
        tagMenuView?.tagCollectionView.reloadData()
        
        self.onSingleTap(recognizer: self.singleTapRecognizer!)
        self.tagMenuView?.newTagNameField.text = ""
    }
}

extension TagEditableViewDelegater: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tagPickerPresenter?.tags[row].name
    }
}

extension TagEditableViewDelegater: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.tagMenuView!.tagCollectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        AlertCreater.yn(title: "タグの削除", message: "このタグを削除しますか？", viewController: self.targetViewController!, y: { (_ a: UIAlertAction?) in
            Tag.delete(cell.id!, from: self.tagMenuView!.note!.id)
            self.tagCollectionPresenter!.load(noteId: self.tagMenuView!.note!.id)
            self.tagMenuView?.tagCollectionView.reloadData()
        }, n: { (_ a: UIAlertAction?) in
            return
        })
    }
}

extension TagEditableViewDelegater: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
}
