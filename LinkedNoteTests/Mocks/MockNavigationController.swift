//
//  MockNavigationController.swift
//  LinkedNoteTests
//
//  Created by Tasuku Tozawa on 2018/02/11.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import UIKit

class MockNavigationController: UINavigationController {
    var pushedViewController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated _: Bool) {
        pushedViewController = viewController
        super.pushViewController(viewController, animated: true)
    }
}
