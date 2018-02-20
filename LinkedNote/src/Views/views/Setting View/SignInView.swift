//
//  SignInView.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/20.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

enum ApiSignatures {
    case Pocket
}

protocol SignInViewDelegate {
    func didPressPocketButton(type: APIWrapper.Type)
}

protocol SignInViewProvider {
    var delegate: SignInViewDelegate? { set get }
    var view: UIView { get }
}

class SignInView: UIView {
    var delegate_: SignInViewDelegate?

    @IBOutlet var view_: UIView!
    @IBOutlet var pocketButton_: UIButton!
    @IBAction func didPressPocketButton(_: Any) {
        self.delegate_?.didPressPocketButton(type: PocketAPIWrapper.self)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("SignIn", owner: self, options: nil)
        view_.frame = frame
        addSubview(view_)

        // TODO: レイアウトの修正。かっこよくする
        pocketButton_.backgroundColor = UIColor.blue
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SignInView: SignInViewProvider {
    var delegate: SignInViewDelegate? {
        get {
            return self.delegate_
        }
        set {
            self.delegate_ = newValue
        }
    }

    var view: UIView {
        return self.view_
    }
}
