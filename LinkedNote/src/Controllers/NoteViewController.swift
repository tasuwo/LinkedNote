//
//  NoteViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class NoteViewController: TagEditableViewController {
    var isAdjusted = false
    var note: Note?
    var view_: NoteView!
    var tagPresenter_: TagCollectionPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let topOffset = self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - topOffset)
        view_ = NoteView(frame: frame)
        view_.noteView.text = note!.body
        view_.delegate = self
        self.view.addSubview(view_)
        
        tagPresenter_ = TagCollectionPresenter()
        tagPresenter_.load(noteId: note!.id)
        self.view_.tagCollectionView.reloadData()
        view_.tagCollectionView.delegate = self
        view_.tagCollectionView.dataSource = tagPresenter_

        self.navigationItem.title = "ノート"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tagEditKeyboardWillBeShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.tagEditKeyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension NoteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.view_.tagCollectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        if let tagId = cell.id {
            let noteListVC = NoteListViewController()
            noteListVC.settings = NodeListViewControllerSettings(title: "タグ: \(cell.name.text!)", tagId: tagId)
            self.navigationController?.pushViewController(noteListVC, animated: true)
        }
    }
}

extension NoteViewController: UICollectionViewDelegateFlowLayout {
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

extension NoteViewController: NoteViewDelegate {
    func didPressEditButton() {
        self.initializeTagEditView(note: self.note!)
    }
    
    func didPressViewArticleButton() {
        
        if let article = self.note?.article {
            let articleVC = ArticleViewController()
            articleVC.article = article
            self.navigationController?.pushViewController(articleVC, animated: true)
        } else {
            AlertCreater.error("ノートに対応する記事の取得に失敗しました", viewController: self)
        }
        
    }
}

extension NoteViewController: DetectableTagMenuViewEvent {
    func didClose() {
        self.tagPresenter_.load(noteId: self.note!.id)
        self.view_.tagCollectionView.reloadData()
    }
}
