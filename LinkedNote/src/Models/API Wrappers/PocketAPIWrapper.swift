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

class PocketAPIWrapper: NSObject, APIWrapper {
    var retrieveUnitNum = 1
    var currentOffset = 0
    var isRetrieving = false
    
    func setUnitNum(_ num: Int) {
        self.retrieveUnitNum = num
    }
    
    func initOffset() {
        self.currentOffset = 0
    }
    
    func retrieve(_ completion: @escaping (([ArticleInfo]) -> Void)) {
        if self.isRetrieving { return }
        self.isRetrieving = true
        self.retrieve(offset: self.currentOffset, count: self.retrieveUnitNum, completion: {(infoArray) in
            completion(infoArray)
            self.currentOffset += self.retrieveUnitNum
            self.isRetrieving = false
        })
    }
    
    fileprivate func retrieve(offset: Int, count: Int, completion: @escaping (_ result: [ArticleInfo])->Void) {
        var result: [ArticleInfo] = []
        if PocketAPI.shared().isLoggedIn {
            let httpMethod = PocketAPIHTTPMethodGET
            let arguments: NSDictionary = ["detailType":"complete", "count":count.description, "offset":offset.description]
            
            PocketAPI.shared().callMethod("get", with: httpMethod, arguments: arguments as! [AnyHashable : Any], handler: {
                (api, apiMethod, response, error) in
                let responseJson: JSON
                if let r = response {
                    responseJson = JSON(r)
                } else {
                    completion(result)
                    return
                }
                
                let posts: Dictionary<String, JSON>
                if let p = responseJson["list"].dictionary {
                    posts = p
                } else {
                    completion(result)
                    return
                }
                
                for (id, json) in posts {
                    var info = ArticleInfo()
                    info.id = id
                    for (key, value) in json {
                        switch key {
                        case "resolved_title":
                            info.title = value.string ?? info.title
                        case "resolved_url":
                            info.url = value.string ?? info.url
                        case "excerpt":
                            info.excerpt = value.string ?? info.excerpt
                        case "image":
                            info.thumbnailUrl = value["src"].string ?? info.thumbnailUrl
                        default: break
                        }
                    }
                    result.append(info)
                }
                completion(result)
            })
        } else {
            completion(result)
        }
    }
}
