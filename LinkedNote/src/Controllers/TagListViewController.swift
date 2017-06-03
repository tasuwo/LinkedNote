//
//  TagListViewController.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class TagListViewController: UIViewController {
    var tagListPresenter: TagListPresenter!
    var view_: TagListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagListPresenter = TagListPresenter()
        let offset = self.navigationController!.tabBarController!.tabBar.frame.height
            + self.navigationController!.navigationBar.frame.height
            + UIApplication.shared.statusBarFrame.height
        let frame = CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.width, height: self.view.frame.height - offset)
        view_ = TagListView(frame: frame)
        view_.tagList.dataSource = tagListPresenter
        view_.tagList.delegate = self
        self.view.addSubview(view_)
        
        self.navigationItem.title = "全ての保存済みのタグ"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tagListPresenter.load()
        self.view_.tagList.reloadData()
    }
}

extension TagListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! TagListCustomCell
        
        if let id = cell.tagId {
            let noteListVC = NoteListViewController()
            noteListVC.settings = NodeListViewControllerSettings(title: "タグ: \(cell.tagName.text!)", tagId: id)
            self.navigationController?.pushViewController(noteListVC, animated: true)
        } else {
            AlertCreater.error("タグの読み込みに必要な情報の取得に失敗しました", viewController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "削除", handler: { (action, indexPath) in
                let cell = self.view_.tagList.cellForRow(at: indexPath) as! TagListCustomCell
                if let tag = Tag.get(cell.tagId!) {
                    Tag.delete(tag)
                    self.tagListPresenter.load()
                    self.view_.tagList.deleteRows(at: [indexPath], with: .automatic)
                }
            })
        ]
    }
}
