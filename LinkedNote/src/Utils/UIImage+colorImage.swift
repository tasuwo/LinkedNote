//
//  UIImage+colorImage.swift
//  LinkedNote
//
//  Created by Tasuku Tozawa on 2018/02/12.
//  Copyright © 2018年 tasuku tozawa. All rights reserved.
//

import UIKit

extension UIImage {
    class func colorImage(color: UIColor, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)

        let rect = CGRect(origin: CGPoint.zero, size: size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}
