//
//  TagEditableViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/01.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol TagEditViewPresenterDelegate {
    func didPressCloseButton()
}

class TagEditViewPresenter: NSObject {
    var delegate: TagEditViewPresenterDelegate?
    var tagMenuView: TagMenuView!
    var targetViewController: UIViewController!
    let tagCollectionPresenter: TagCollectionPresenter
    let tagPickerPresenter: TagPickerPresenter
    var singleTapRecognizer: UITapGestureRecognizer!

    var fullScrnFrame: CGRect?
    var isNewTagNameEditing: Bool = false

    let alertPresenter: AlertPresenter

    init(alertPresenter: AlertPresenter) {
        self.alertPresenter = alertPresenter
        self.tagPickerPresenter = TagPickerPresenter()
        self.tagPickerPresenter.reload()

        self.tagCollectionPresenter = TagCollectionPresenter()

        super.init()
    }

    func initwith(note: Note, frame: CGRect) {
        self.tagMenuView = TagMenuView(frame: frame)
        self.tagMenuView.delegate = self
        self.tagMenuView.note = note

        self.tagMenuView.tagPicker.delegate = self
        self.tagMenuView.tagPicker.dataSource = tagPickerPresenter

        self.tagMenuView.tagCollectionView.dataSource = self.tagCollectionPresenter
        self.tagMenuView.tagCollectionView.delegate = self
        self.tagMenuView.tagCollectionView.reloadData()

        self.tagCollectionPresenter.load(noteId: note.id)

        self.fullScrnFrame = self.tagMenuView.frame

        // Recognize the touch to out of text field
        self.singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onSingleTap(recognizer:)))
        self.singleTapRecognizer.delegate = self
    }

    func add(to view: UIView, viewController: UIViewController) {
        let transition = CATransition()
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.15
        transition.type = kCATransitionFade

        view.layer.add(transition, forKey: kCATransition)
        view.addSubview(tagMenuView)

        self.targetViewController = viewController

        self.tagMenuView.view_.addGestureRecognizer(self.singleTapRecognizer)
    }
}

extension TagEditViewPresenter {
    func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tagEditKeyboardWillBeShown(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tagEditKeyboardWillBeHidden(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension TagEditViewPresenter {
    func tagEditKeyboardWillBeShown(notification: NSNotification) {
        if let tagNameField = self.tagMenuView.newTagNameField {
            if tagNameField.isFirstResponder == false { return }
        } else { return }

        if self.isNewTagNameEditing { return }
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
                let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {

                let convertedKeyboardFrame = self.tagMenuView.convert(keyboardFrame, from: nil)
                UIView.animate(withDuration: animationDuration, animations: {
                    self.tagMenuView.frame = self.tagMenuView.frame.insetBy(dx: 0, dy: -1 * (convertedKeyboardFrame.height))
                }, completion: { _ in })
            }
        }
        self.isNewTagNameEditing = true
    }

    func tagEditKeyboardWillBeHidden(notification: NSNotification) {
        if let tagNameField = self.tagMenuView.newTagNameField {
            if tagNameField.isFirstResponder == false { return }
        } else { return }

        if let userInfo = notification.userInfo {
            if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                UIView.animate(withDuration: animationDuration, animations: {
                    self.tagMenuView.frame = self.fullScrnFrame!
                }, completion: { _ in })
            }
        }
        self.isNewTagNameEditing = false
    }
}

extension TagEditViewPresenter: UIGestureRecognizerDelegate {
    func onSingleTap(recognizer _: UIGestureRecognizer) {
        self.tagMenuView.newTagNameField.resignFirstResponder()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer {
            if self.tagMenuView.newTagNameField.isFirstResponder {
                return true
            } else {
                return false
            }
        }
        return true
    }
}

extension TagEditViewPresenter: TagMenuViewDelegate {
    func didPressCloseButton() {
        UIView.animate(withDuration: 0.2 as TimeInterval, animations: {
            self.tagMenuView.alpha = 0
        }, completion: { _ in
            self.tagMenuView.removeFromSuperview()
            self.delegate?.didPressCloseButton()
        })
    }

    func didPressSelectExistTagButton(_ index: Int) {
        let selectedTag = tagPickerPresenter.tags[index]
        let selectedNote = self.tagMenuView.note!
        Tag.add(selectedTag, to: selectedNote)

        tagCollectionPresenter.load(noteId: tagMenuView.note!.id)
        tagMenuView.tagCollectionView.reloadData()
    }

    func didPressCreateNewTagButton(_ newTagName: String) {
        let newTag = Tag(name: newTagName)
        Tag.add(newTag)

        let selectedNote = self.tagMenuView.note!
        Tag.add(newTag, to: selectedNote)

        tagCollectionPresenter.load(noteId: tagMenuView.note!.id)
        tagMenuView.tagCollectionView.reloadData()

        self.onSingleTap(recognizer: self.singleTapRecognizer)
        self.tagMenuView.newTagNameField.text = ""
    }
}

extension TagEditViewPresenter: UIPickerViewDelegate {
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return tagPickerPresenter.tags[row].name
    }
}

extension TagEditViewPresenter: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.tagMenuView.tagCollectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        self.alertPresenter.yn(title: "タグの削除", message: "このタグを削除しますか？", on: self.targetViewController, y: { (_: UIAlertAction?) in
            Tag.delete(cell.id!, from: self.tagMenuView.note!.id)
            self.tagCollectionPresenter.load(noteId: self.tagMenuView.note!.id)
            self.tagMenuView.tagCollectionView.reloadData()
        }, n: { (_: UIAlertAction?) in
            return
        })
    }
}

extension TagEditViewPresenter: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 30)
    }

    func collectionView(_: UICollectionView,
                        layout _: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
        return 1.0
    }

    func collectionView(_: UICollectionView, layout
        _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int) -> CGFloat {
        return 1.0
    }
}
