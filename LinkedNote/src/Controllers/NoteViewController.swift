//
//  NoteViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    var noteView: NoteView!
    var isAdjusted = false
    let note: Note
    let tagPresenter: TagCollectionPresenter
    let tagEditViewPresenter: TagEditViewPresenter
    
    init(note: Note) {
        self.note = note
        self.tagPresenter = TagCollectionPresenter()
        self.tagEditViewPresenter = TagEditViewPresenter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topOffset = self.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - topOffset)
        self.noteView = NoteView(frame: frame)
        self.noteView.noteView.text = note.body
        self.noteView.delegate = self
        self.view.addSubview(self.noteView)
        
        tagPresenter.load(noteId: note.id)
        self.noteView.tagCollectionView.reloadData()
        noteView.tagCollectionView.delegate = self
        noteView.tagCollectionView.dataSource = tagPresenter
        
        self.tagEditViewPresenter.delegate = self
        
        self.navigationItem.title = "ノート"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tagEditViewPresenter.addObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tagEditViewPresenter.removeObserver()
    }
}

extension NoteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.noteView.tagCollectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        if let tagId = cell.id {
            let settings = NodeListViewControllerSettings(title: "タグ: \(cell.name.text!)", tagId: tagId)
            let noteListVC = NoteListViewController(settings: settings)
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
        self.tagEditViewPresenter.initwith(note: self.note, frame: self.tabBarController!.view.frame)
        self.tagEditViewPresenter.add(to: self.tabBarController!.view, viewController: self)
    }
    
    func didPressViewArticleButton() {
        if self.note.article == nil {
            AlertCreater.error("ノートに対応する記事の取得に失敗しました", viewController: self)
            return
        }
        let articleVC = ArticleViewController(article: self.note.article!)
        self.navigationController?.pushViewController(articleVC, animated: true)
    }
}

extension NoteViewController: TagEditViewPresenterDelegate {
    func didPressCloseButton() {
        self.tagPresenter.load(noteId: self.note.id)
        self.noteView.tagCollectionView.reloadData()
    }
}
