//
//  MockTagEditViewPresenter.swift
//  LinkedNoteTests
//
//  Created by Tasuku Tozawa on 2018/02/11.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import UIKit

class MockTagEditViewPresenter: TagEditViewPresenter {
    private(set) var isAdded = false

    override func add(to view: UIView, viewController: UIViewController) {
        self.isAdded = true
        super.add(to: view, viewController: viewController)
    }
}
