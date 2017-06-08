//
//  FrameCalculator.swift
//  LinkedNote
//
//  Created by 兎澤　佑　 on 2017/06/08.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

protocol FrameCalculator {
    func calcFrameOnTabAndNavBar(by: UIViewController) -> CGRect
    func calcFrameOnNavVar(by: UIViewController) -> CGRect
}

class FrameCalculatorImplement: FrameCalculator {
    func calcFrameOnTabAndNavBar(by vc: UIViewController) -> CGRect {
        let offset = vc.navigationController!.tabBarController!.tabBar.frame.height
            + vc.navigationController!.navigationBar.frame.height
            + UIApplication.shared.statusBarFrame.height
        return CGRect(x: vc.view.frame.origin.x, y: vc.view.frame.origin.y, width: vc.view.frame.width, height: vc.view.frame.height - offset)
    }
    
    func calcFrameOnNavVar(by vc: UIViewController) -> CGRect {
        let viewBounds = vc.view.bounds;
        let topBarOffSet = vc.navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.size.height
        return CGRect(x: 0, y: 0, width: viewBounds.width, height: viewBounds.height - topBarOffSet)
    }
}
