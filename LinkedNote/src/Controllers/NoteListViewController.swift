//
//  NoteListView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

struct NodeListViewControllerSettings {
    var title: String
    var tagId: Int?
}

class NoteListViewController: UIViewController {
    var noteListView: NoteListView!
    var tagMenuView: TagMenuView?
    let calculator: FrameCalculator
    let noteListPresenter: NoteListPresenter
    let settings: NodeListViewControllerSettings
    let alertPresenter: AlertPresenter
    let tagEditViewPresenter: TagEditViewPresenter

    init(settings: NodeListViewControllerSettings, calculator: FrameCalculator, alertPresenter: AlertPresenter) {
        self.settings = settings
        self.calculator = calculator
        self.alertPresenter = alertPresenter
        self.noteListPresenter = NoteListPresenter()
        self.tagEditViewPresenter = TagEditViewPresenter(alertPresenter: alertPresenter)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize and add a view
        self.noteListView = NoteListView(frame: self.calculator.calcFrameOnTabAndNavBar(by: self))
        self.noteListView.noteList.dataSource = noteListPresenter
        self.noteListView.noteList.delegate = self
        self.view.addSubview(self.noteListView)

        // For recognize long press to table cell
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = self
        self.noteListView.noteList.addGestureRecognizer(longPressGesture)

        self.navigationItem.title = settings.title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_: Bool) {
        self.noteListPresenter.load(settings.tagId)
        self.noteListView.noteList.reloadData()
    }
}

extension NoteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! NoteListCustomCell

        if let note = cell.note {
            let noteVC = NoteViewController(note: note, calculator: self.calculator, alertPresenter: self.alertPresenter)
            self.navigationController?.pushViewController(noteVC, animated: true)
        } else {
            self.alertPresenter.error("ノートの読み込みに必要な情報の取得に失敗しました", on: self)
        }
    }

    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "削除", handler: { _, indexPath in
                let cell = self.noteListView.noteList.cellForRow(at: indexPath) as! NoteListCustomCell
                Note.delete(note: cell.note!)
                self.noteListPresenter.load(self.settings.tagId)
                self.noteListView.noteList.deleteRows(at: [indexPath], with: .automatic)
            }),
        ]
    }
}

extension NoteListViewController: UIGestureRecognizerDelegate {
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        guard longPressGestureRecognizer.state == UIGestureRecognizerState.began else {
            return
        }

        let touchPoint = longPressGestureRecognizer.location(in: self.view)
        guard let indexPath = self.noteListView.noteList.indexPathForRow(at: touchPoint) else {
            return
        }

        let cell = self.noteListView.noteList.cellForRow(at: indexPath) as! NoteListCustomCell
        guard let note = cell.note else {
            return
        }

        self.tagEditViewPresenter.initwith(note: note, frame: self.tabBarController!.view.frame)
        self.tagEditViewPresenter.add(to: self.tabBarController!.view, viewController: self)
    }
}
