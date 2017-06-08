//
//  displayErrorAlert.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/05/31.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit

class AlertPresenterImplement {
    static func error(_ message: String, viewController vc: UIViewController) {
        let alert: UIAlertController = UIAlertController(title: "Error", message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let action: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("OK")
        })
        
        alert.addAction(action)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func yn(title: String, message: String, viewController vc: UIViewController, y: @escaping (_ action: UIAlertAction?) -> Void, n: @escaping (_ action: UIAlertAction?) -> Void) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        
        let actionYes: UIAlertAction = UIAlertAction(title: "はい", style: UIAlertActionStyle.default, handler:y)
        let actionNo: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertActionStyle.default, handler:n)
        alert.addAction(actionNo)
        alert.addAction(actionYes)
        
        vc.present(alert, animated: true, completion: nil)
    }
}
