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
    let tagListPresenter: TagListPresenter
    
    init() {
        self.tagListPresenter = TagListPresenter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let offset = self.navigationController!.tabBarController!.tabBar.frame.height
            + self.navigationController!.navigationBar.frame.height
            + UIApplication.shared.statusBarFrame.height
        let frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height - offset)

        self.tagListView = TagListView(frame: frame)
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
            let noteListVC = NoteListViewController(settings: settings)
            self.navigationController?.pushViewController(noteListVC, animated: true)
        } else {
            AlertCreater.error("タグの読み込みに必要な情報の取得に失敗しました", viewController: self)
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
