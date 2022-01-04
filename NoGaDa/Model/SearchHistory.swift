//
//  SearchHistory.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/10.
//

import UIKit
import RealmSwift

class SearchHistory: Object {
    @objc dynamic var keyword: String = ""
    @objc dynamic var date: Date = Date()
    
    convenience init(keyword: String) {
        self.init()
        
        self.keyword = keyword
    }
    
    override class func primaryKey() -> String? {
        return "keyword"
    }
}
