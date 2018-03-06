//
//  FakeAlertPresenters.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import UIKit

class FakeAlertPresenter: AlertPresenter {
    var lastErrorMessage: String?
    var lastYNMessage: String?
    var lastCheckMessage: String?

    func error(_ message: String, on _: UIViewController) {
        self.lastErrorMessage = message
    }

    func check(_: String, _ message: String, on _: UIViewController, _: @escaping (UIAlertAction?) -> Void) {
        self.lastCheckMessage = message
    }

    func yn(title _: String, message: String, on _: UIViewController, y _: @escaping (UIAlertAction?) -> Void, n _: @escaping (UIAlertAction?) -> Void) {
        self.lastYNMessage = message
    }
}
