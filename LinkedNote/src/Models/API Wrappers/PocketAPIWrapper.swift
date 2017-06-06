//
//  PocketApiWrapper.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import UIKit
import PocketAPI
import SwiftyJSON

fileprivate struct ArticleInfo {
    var localId: String? = nil
    var title: String? = nil
    var url: String? = nil
    var excerpt: String? = nil
    var thumbnailUrl: String? = nil
    
    func isInvalid() -> Bool {
        return localId != nil && title != nil && url != nil && excerpt != nil && thumbnailUrl != nil
    }
}

class PocketAPIWrapper: NSObject, APIWrapper {
    var retrieveUnitNum = 1
    var currentOffset = 0
    var isRetrieving = false
    let signature = "pocket"
    private var username: String?
    
    func setUnitNum(_ num: Int) {
        self.retrieveUnitNum = num
    }
    
    func initOffset() {
        self.currentOffset = 0
    }
    
    func retrieve(_ completion: @escaping (([Article]) -> Void)) {
        if self.isRetrieving { return }
        self.isRetrieving = true
        self.retrieve(offset: self.currentOffset, count: self.retrieveUnitNum, completion: {(infoArray) in
            completion(infoArray)
            self.currentOffset += self.retrieveUnitNum
            self.isRetrieving = false
        })
    }
    
    fileprivate func retrieve(offset: Int, count: Int, completion: @escaping (_ result: [Article])->Void) {
        var result: [Article] = []
        
        if !PocketAPI.shared().isLoggedIn {
            completion(result)
            return
        }
        
        if let username = PocketAPI.shared().username,
           let account = ApiAccount.get(apiSignature: self.signature, username: username) {
            
            let httpMethod = PocketAPIHTTPMethodGET
            let arguments: NSDictionary = ["detailType":"complete", "count":count.description, "offset":offset.description]
            
            PocketAPI.shared().callMethod("get", with: httpMethod, arguments: arguments as! [AnyHashable : Any], handler: { (api, apiMethod, response, error) in
                let responseJson: JSON
                if let r = response {
                    responseJson = JSON(r)
                } else {
                    completion(result)
                    return
                }
                
                let articles: Dictionary<String, JSON>
                if let p = responseJson["list"].dictionary {
                    articles = p
                } else {
                    completion(result)
                    return
                }
                
                for (id, json) in articles {
                    var info = ArticleInfo()
                    info.localId = id
                    for (key, value) in json {
                        switch key {
                        case "resolved_title":
                            info.title = value.string
                        case "resolved_url":
                            info.url = value.string
                        case "excerpt":
                            info.excerpt = value.string
                        case "image":
                            info.thumbnailUrl = value["src"].string
                        default: break
                        }
                    }
                    
                    if info.isInvalid() == false {
                        continue
                    }
                    
                    if let storedArticle = Article.get(localId: info.localId!, accountId: account.id) {
                        result.append(storedArticle)
                    } else {
                        result.append(Article(localId: info.localId!, title: info.title!, url: info.url!, thumbnailUrl: info.thumbnailUrl!))
                    }
                }
                completion(result)
            })
        } else {
            completion(result)
        }
    }
    
    func archive(id: String, completion: @escaping ((Bool) -> Void)) {
        if PocketAPI.shared().isLoggedIn {
            let time = Int(NSDate().timeIntervalSince1970)
            let httpMethod = PocketAPIHTTPMethodPOST
            let arguments: NSDictionary = [ "actions": [ [ "action": "archive", "item_id": "\(id)", "time": "\(time.description)" ] ] ]
            
            PocketAPI.shared().callMethod("send", with: httpMethod, arguments: arguments as! [AnyHashable : Any], handler: {
                (api, apiMethod, response, error) in
                Swift.print(error?.localizedDescription ?? "")
                let responseJson: JSON
                if let r = response {
                    responseJson = JSON(r)
                } else {
                    completion(false)
                    return
                }
                
                Swift.print(responseJson["action_results"].array![0])
                Swift.print(responseJson["status"])
                completion(true)
            })
        }
    }
}
