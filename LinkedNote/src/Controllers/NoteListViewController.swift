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
    let tagPickerPresenter: TagPickerPresenter
    let settings: NodeListViewControllerSettings
    
    init(settings: NodeListViewControllerSettings, calculator: FrameCalculator) {
        self.settings = settings
        self.calculator = calculator
        self.noteListPresenter = NoteListPresenter()
        self.tagPickerPresenter = TagPickerPresenter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        let longPressGesture: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLogPress))
        longPressGesture.minimumPressDuration = 0.7
        longPressGesture.delegate = self
        self.noteListView.noteList.addGestureRecognizer(longPressGesture)
        
        self.navigationItem.title = settings.title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.noteListPresenter.load(settings.tagId)
        self.noteListView.noteList.reloadData()
    }
}
    
extension NoteListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as! NoteListCustomCell
        
        if let note = cell.note {
            let noteVC = NoteViewController(note: note, calculator: self.calculator)
            self.navigationController?.pushViewController(noteVC, animated: true)
        } else {
            AlertPresenterImplement.error("ノートの読み込みに必要な情報の取得に失敗しました", viewController: self)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "削除", handler: { (action, indexPath) in
                let cell = self.noteListView.noteList.cellForRow(at: indexPath) as! NoteListCustomCell
                Note.delete(note: cell.note!)
                self.noteListPresenter.load(self.settings.tagId)
                self.noteListView.noteList.deleteRows(at: [indexPath], with: .automatic)
            })
        ]
    }
}

extension NoteListViewController: UIGestureRecognizerDelegate {
    func handleLogPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: self.view)
            if let indexPath = self.noteListView.noteList.indexPathForRow(at: touchPoint) {
                
                let cell = self.noteListView.noteList.cellForRow(at: indexPath) as! NoteListCustomCell
                
                self.tagMenuView = TagMenuView(frame: self.tabBarController!.view.frame)
                self.tagMenuView!.note = cell.note
                
                tagPickerPresenter.reload()
                self.tagMenuView!.tagPicker.dataSource = tagPickerPresenter
                self.tagMenuView!.tagPicker.delegate = self
                
                let transition = CATransition()
                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                transition.duration = 0.15
                transition.type = kCATransitionFade
                self.tabBarController?.view.layer.add(transition, forKey: kCATransition)
 
                self.tabBarController?.view.addSubview(self.tagMenuView!)
            }
        }
    }
}

extension NoteListViewController: TagMenuViewDelegate {
    func didPressCloseButton() {
        UIView.animate(withDuration: 0.2 as TimeInterval, animations: {
            self.tagMenuView!.alpha = 0
        }, completion: { finished in
            self.tagMenuView!.removeFromSuperview()
            self.tagMenuView = nil
        })
    }
    
    func didPressSelectExistTagButton(_ index: Int) {
        let selectedTag = tagPickerPresenter.tags[index]
        let selectedNote = self.tagMenuView!.note!
        Tag.add(selectedTag, to: selectedNote)
        self.didPressCloseButton()
    }
    
    func didPressCreateNewTagButton(_ newTagName: String) {
        let newTag = Tag(name: newTagName)
        Tag.add(newTag)
        
        let selectedNote = self.tagMenuView!.note!
        Tag.add(newTag, to: selectedNote)
        self.didPressCloseButton()
    }
}

extension NoteListViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tagPickerPresenter.tags[row].name
    }
}
