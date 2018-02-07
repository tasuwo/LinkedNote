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
    var provider: TagMenuViewProvider!
    var targetViewController: UIViewController!
    let tagCollectionPresenter: TagCollectionPresenter
    let tagPickerPresenter: TagPickerPresenter
    var singleTapRecognizer: UITapGestureRecognizer!

    var fullScrnFrame: CGRect?
    var isNewTagNameEditing: Bool = false

    let alertPresenter: AlertPresenter

    let tagRepository: Repository<Tag>

    init(alertPresenter: AlertPresenter) {
        self.alertPresenter = alertPresenter
        self.tagPickerPresenter = TagPickerPresenter()
        self.tagPickerPresenter.reload()

        self.tagCollectionPresenter = TagCollectionPresenter()

        // TODO: Factory pattern
        self.tagRepository = Repository<Tag>()

        super.init()
    }

    func initwith(provider: TagMenuViewProvider, note: Note, frame: CGRect) {
        self.provider = provider
        self.provider.view.frame = frame
        self.provider.baseView.frame = frame
        self.provider.blurEffectView.frame = frame

        self.provider.setDelegate(self)
        self.provider.setNote(note)

        self.provider.tagPicker.delegate = self
        self.provider.tagPicker.dataSource = tagPickerPresenter

        self.provider.tagCollectionView.dataSource = self.tagCollectionPresenter
        self.provider.tagCollectionView.delegate = self
        self.provider.tagCollectionView.reloadData()

        self.tagCollectionPresenter.load(noteId: note.id)

        self.fullScrnFrame = self.provider.view.frame

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
        view.addSubview(self.provider.view)

        self.targetViewController = viewController

        self.provider.view.addGestureRecognizer(self.singleTapRecognizer)
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
        if self.provider.newTagNameField.isFirstResponder == false {
            return
        }

        if self.isNewTagNameEditing { return }
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
                let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                let convertedKeyboardFrame = self.provider.view.convert(keyboardFrame, from: nil)
                UIView.animate(withDuration: animationDuration, animations: {
                    self.provider.view.frame = self.provider.view.frame.insetBy(dx: 0, dy: -1 * (convertedKeyboardFrame.height))
                }, completion: { _ in })
            }
        }
        self.isNewTagNameEditing = true
    }

    func tagEditKeyboardWillBeHidden(notification: NSNotification) {
        if self.provider.newTagNameField.isFirstResponder == false {
            return
        }

        if let userInfo = notification.userInfo {
            if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                UIView.animate(withDuration: animationDuration, animations: {
                    self.provider.view.frame = self.fullScrnFrame!
                }, completion: { _ in })
            }
        }
        self.isNewTagNameEditing = false
    }
}

extension TagEditViewPresenter: UIGestureRecognizerDelegate {
    func onSingleTap(recognizer _: UIGestureRecognizer) {
        self.provider.newTagNameField.resignFirstResponder()
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        if gestureRecognizer == self.singleTapRecognizer {
            if self.provider.newTagNameField.isFirstResponder {
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
            self.provider.view.alpha = 0
        }, completion: { _ in
            self.provider.view.removeFromSuperview()
            self.delegate?.didPressCloseButton()
        })
    }

    func didPressSelectExistTagButton(_ index: Int) {
        let selectedTag = tagPickerPresenter.tags[index]
        let selectedNote = self.provider.note!
        try! tagRepository.add(selectedTag, to: selectedNote)

        tagCollectionPresenter.load(noteId: self.provider.note!.id)
        self.provider.tagCollectionView.reloadData()
    }

    func didPressCreateNewTagButton(_ newTagName: String) {
        let newTag = Tag(name: newTagName)
        try! tagRepository.add(newTag)

        let selectedNote = self.provider.note!
        try! tagRepository.add(newTag, to: selectedNote)

        tagCollectionPresenter.load(noteId: self.provider.note!.id)
        self.provider.tagCollectionView.reloadData()

        self.onSingleTap(recognizer: self.singleTapRecognizer)
        self.provider.newTagNameField.text = ""
    }
}

extension TagEditViewPresenter: UIPickerViewDelegate {
    func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return tagPickerPresenter.tags[row].name
    }
}

extension TagEditViewPresenter: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.provider.tagCollectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        self.alertPresenter.yn(title: "タグの削除", message: "このタグを削除しますか？", on: self.targetViewController, y: { (_: UIAlertAction?) in
            try! self.tagRepository.delete(cell.id!, from: self.provider.note!.id)
            self.tagCollectionPresenter.load(noteId: self.provider.note!.id)
            self.provider.tagCollectionView.reloadData()
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
