//
//  AccountView.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/29.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol SignInViewDelegate {
    func didTouchLoginButton()
}

class SignInView: UIView {
    var delegate: SignInViewDelegate?
    @IBOutlet var view_: UIView!
    @IBAction func didTouchLoginButton(_ sender: Any) {
        self.delegate?.didTouchLoginButton()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("SignIn", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
