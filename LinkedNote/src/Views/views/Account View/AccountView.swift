//
//  Account.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol AccountViewDelegate {
    func didTouchLogOutButton()
}

class AccountView: UIView {
    var delegate: AccountViewDelegate?
    @IBOutlet var view_: UIView!
    @IBAction func didTouchLogOutButton(_: Any) {
        self.delegate?.didTouchLogOutButton()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("Account", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
