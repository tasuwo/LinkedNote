//
//  FakeAlertPresenters.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
@testable import LinkedNote

class FakeAlertPresenter: AlertPresenter {
    func error(_ message: String, on: UIViewController) {}
    func yn(title: String, message: String, on vc: UIViewController, y: @escaping (UIAlertAction?) -> Void, n: @escaping (UIAlertAction?) -> Void) {}
}
