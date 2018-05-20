//
//  PocketApiWrapper.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

import PocketAPI
import SwiftyJSON
import UIKit

fileprivate struct ArticleInfo {
    var localId: String?
    var title: String?
    var url: String?
    var excerpt: String?
    var thumbnailUrl: String?

    func isAbleToCastToArticleDataModel() -> Bool {
        return localId != nil && title != nil && url != nil && excerpt != nil && thumbnailUrl != nil
    }
}

class PocketAPIWrapper: NSObject, APIWrapper {
    var retrieveUnitNum = 1
    var currentOffset = 0
    var isRetrieving = false
    static let signature = "pocket"
    private var username: String?

    private let accountRepo: Repository<ApiAccount>
    private let articleRepo: Repository<Article>

    override init() {
        accountRepo = Repository<ApiAccount>()
        articleRepo = Repository<Article>()
    }

    static func getUsername() -> String? {
        if PocketAPI.shared().isLoggedIn {
            return PocketAPI.shared().username
        } else {
            return nil
        }
    }

    static func isLoggedIn() -> Bool {
        return PocketAPI.shared().isLoggedIn
    }

    static func logout() {
        PocketAPI.shared().logout()
    }

    static func login(completion: @escaping (APIError?) -> Void) {
        PocketAPI.shared().login(handler: { _, error in
            if let e = error {
                completion(APIError.APIError(e))
            }
            completion(nil)
        })
    }

    func setUnitNum(_ num: Int) {
        self.retrieveUnitNum = num
    }

    func initOffset() {
        self.currentOffset = 0
    }

    func retrieve(_ completion: @escaping (([Article], APIError?) -> Void)) {
        if self.isRetrieving { return }
        self.isRetrieving = true
        self.retrieve(offset: self.currentOffset, count: self.retrieveUnitNum, state: "unread", completion: { infoArray, error in
            completion(infoArray, error)
            self.currentOffset += self.retrieveUnitNum
            self.isRetrieving = false
        })
    }

    func retrieveArchives(_ completion: @escaping (([Article], APIError?) -> Void)) {
        if self.isRetrieving { return }
        self.isRetrieving = true
        self.retrieve(offset: self.currentOffset, count: self.retrieveUnitNum, state: "archive", completion: { infoArray, error in
            completion(infoArray, error)
            self.currentOffset += self.retrieveUnitNum
            self.isRetrieving = false
        })
    }

    fileprivate func retrieve(offset: Int, count: Int, state: String, completion: @escaping (_ result: [Article], _ error: APIError?) -> Void) {
        var result: [Article] = []

        if !PocketAPI.shared().isLoggedIn {
            completion([], APIError.NotLoggedIn)
            return
        }

        guard let username = PocketAPI.shared().username else {
            completion([], APIError.FailedToGetUserNameByAPI)
            return
        }

        guard let account = accountRepo.find(apiSignature: PocketAPIWrapper.signature, username: username) else {
            completion([], APIError.UserNotFoundInDatabase)
            return
        }

        let httpMethod = PocketAPIHTTPMethodGET
        let arguments: NSDictionary = [
            "detailType": "complete",
            "count": count.description,
            "offset": offset.description,
            "sort": "newest",
            "state": state,
        ]

        PocketAPI.shared().callMethod("get", with: httpMethod, arguments: arguments as! [AnyHashable: Any], handler: {
            _, _, response, error in

            if let e = error {
                Swift.print(e.localizedDescription)
                completion([], APIError.APIError(e))
                return
            }

            guard let responseStr = response else {
                completion([], APIError.ResponseIsNil)
                return
            }
            let responseJson = JSON(responseStr)

            // TODO: API response format validation

            guard let articles: Dictionary<String, JSON> = responseJson["list"].dictionary else {
                completion([], APIError.UnexpectedAPIResponseFormat)
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

                if info.thumbnailUrl == nil {
                    info.thumbnailUrl = ""
                }

                if info.isAbleToCastToArticleDataModel() == false {
                    Swift.print("Couldn't convert to Artcile \(info)")
                    continue
                }

                if let storedArticle = self.articleRepo.find(localId: info.localId!, accountId: account.id) {
                    result.append(storedArticle)
                } else {
                    result.append(Article(localId: info.localId!, title: info.title!, url: info.url!, thumbnailUrl: info.thumbnailUrl!))
                }
            }

            completion(result, nil)
        })
    }

    func archive(id: String, completion: @escaping ((APIError?) -> Void)) {
        send(action: "archive", id: id, completion: completion)
    }

    func delete(id: String, completion: @escaping ((APIError?) -> Void)) {
        send(action: "delete", id: id, completion: completion)
    }

    func readd(id: String, completion: @escaping ((APIError?) -> Void)) {
        send(action: "readd", id: id, completion: completion)
    }

    fileprivate func send(action: String, id: String, completion: @escaping ((APIError?) -> Void)) {
        if !PocketAPI.shared().isLoggedIn {
            completion(APIError.NotLoggedIn)
            return
        }

        let time = Int(NSDate().timeIntervalSince1970)
        let httpMethod = PocketAPIHTTPMethodPOST
        let arguments: NSDictionary = [
            "actions": [[
                "action": action,
                "item_id": "\(id)",
                "time": "\(time.description)",
            ]],
        ]

        // TODO: API Response format validation

        PocketAPI.shared().callMethod("send", with: httpMethod, arguments: arguments as! [AnyHashable: Any], handler: {
            _, _, response, error in

            if let e = error {
                Swift.print(e.localizedDescription)
                completion(APIError.APIError(e))
                return
            }

            guard let responseStr = response else {
                Swift.print("Pocket API return nil response")
                completion(APIError.ResponseIsNil)
                return
            }

            let responseJson = JSON(responseStr)
            Swift.print(responseJson["action_results"].array![0])
            Swift.print(responseJson["status"])

            completion(nil)
        })
    }
}
