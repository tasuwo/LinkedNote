//
//  APIWrapper.swift
//  linkedNote
//
//  Created by 兎澤　佑　 on 2017/06/02.
//  Copyright © 2017年 tasuku tozawa. All rights reserved.
//

protocol APIWrapper {
    func setUnitNum(_ num: Int)
    func initOffset()
    func retrieve(_ completion: @escaping (([ArticleInfo]) -> Void))
}
