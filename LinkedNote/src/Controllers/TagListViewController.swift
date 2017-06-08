//
//  TagListViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class TagListViewController: UIViewController {
    var tagListView: TagListView!
    let calculator: FrameCalculator
    let tagListPresenter: TagListPresenter
    
    init(calculator: FrameCalculator) {
        self.calculator = calculator
        self.tagListPresenter = TagListPresenter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tagListView = TagListView(frame: self.calculator.calcFrameOnTabAndNavBar(by: self))
        self.tagListView.tagList.dataSource = tagListPresenter
        self.tagListView.tagList.delegate = self
        self.view.addSubview(tagListView)
        
        self.navigationItem.title = "全ての保存済みのタグ"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tagListPresenter.load()
        self.tagListView.tagList.reloadData()
    }
}

extension TagListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! TagListCustomCell
        
        if let id = cell.tagId {
            let settings = NodeListViewControllerSettings(title: "タグ: \(cell.tagName.text!)", tagId: id)
            let noteListVC = NoteListViewController(settings: settings, calculator: self.calculator)
            self.navigationController?.pushViewController(noteListVC, animated: true)
        } else {
            AlertPresenterImplement.error("タグの読み込みに必要な情報の取得に失敗しました", viewController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "削除", handler: { (action, indexPath) in
                let cell = self.tagListView.tagList.cellForRow(at: indexPath) as! TagListCustomCell
                if let tag = Tag.get(cell.tagId!) {
                    Tag.delete(tag)
                    self.tagListPresenter.load()
                    self.tagListView.tagList.deleteRows(at: [indexPath], with: .automatic)
                }
            })
        ]
    }
}
