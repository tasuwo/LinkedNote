//
//  NoteViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
    let provider: NoteViewProvider
    let calculator: FrameCalculator
    var isAdjusted = false
    let note: Note
    let tagPresenter: TagCollectionPresenter
    let tagEditViewPresenter: TagEditViewPresenter
    let alertPresenter: AlertPresenter

    init(provider: NoteViewProvider, note: Note, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.provider = provider
        self.note = note
        self.calculator = calculator
        self.alertPresenter = alertPresenter
        self.tagPresenter = TagCollectionPresenter()
        self.tagEditViewPresenter = TagEditViewPresenter(alertPresenter: alertPresenter)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.provider.view.frame = self.calculator.calcFrameOnNavVar(by: self)
        self.provider.noteView.text = note.body
        self.provider.setNoteViewDelegate(self)
        self.view.addSubview(self.provider.view)

        tagPresenter.load(noteId: note.id)
        self.provider.tagCollectionView.reloadData()
        self.provider.tagCollectionView.delegate = self
        self.provider.tagCollectionView.dataSource = tagPresenter

        self.tagEditViewPresenter.delegate = self

        self.navigationItem.title = "ノート"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        self.tagEditViewPresenter.addObserver()
    }

    override func viewWillDisappear(_: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tagEditViewPresenter.removeObserver()
    }
}

extension NoteViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = self.provider.tagCollectionView.cellForItem(at: indexPath) as! TagCollectionViewCell
        if let tagId = cell.id {
            let settings = NodeListViewControllerSettings(title: "タグ: \(cell.name.text!)", tagId: tagId)
            let noteListVC = NoteListViewController(provider: NoteListView(), settings: settings, calculator: self.calculator, alertPresenter: self.alertPresenter)
            self.navigationController?.pushViewController(noteListVC, animated: true)
        }
    }
}

extension NoteViewController: UICollectionViewDelegateFlowLayout {
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

extension NoteViewController: NoteViewDelegate {
    func didPressEditButton() {
        self.tagEditViewPresenter.initwith(provider: TagMenuView(), note: self.note, frame: self.tabBarController!.view.frame)
        self.tagEditViewPresenter.add(to: self.tabBarController!.view, viewController: self)
    }

    func didPressViewArticleButton() {
        if self.note.article == nil {
            self.alertPresenter.error("ノートに対応する記事の取得に失敗しました", on: self)
            return
        }
        let articleVC = ArticleViewController(provider: ArticleView(), article: self.note.article!, calculator: self.calculator, alertPresenter: self.alertPresenter)
        self.navigationController?.pushViewController(articleVC, animated: true)
    }
}

extension NoteViewController: TagEditViewPresenterDelegate {
    func didPressCloseButton() {
        self.tagPresenter.load(noteId: self.note.id)
        self.provider.tagCollectionView.reloadData()
    }
}
