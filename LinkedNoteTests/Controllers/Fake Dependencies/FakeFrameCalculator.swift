//
//  FakeFrameCalculators.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

@testable import LinkedNote
import UIKit

class FakeFrameCalculator: FrameCalculator {
    func calcFrameOnTabAndNavBar(by: UIViewController) -> CGRect {
        return by.view.frame
    }

    func calcFrameOnNavVar(by: UIViewController) -> CGRect {
        return by.view.frame
    }
}
