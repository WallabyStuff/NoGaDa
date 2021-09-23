//
//  SearchFilterItem.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/21.
//

import UIKit

enum SearchFilterItem: String, CaseIterable {
    case searchWithTitle    = "searchWithTitle"
    case searchWithSinger   = "searchWithSinger"
    
    var title: String {
        switch self {
        case .searchWithTitle:
            return "제목으로 검색"
        case .searchWithSinger:
            return "가수명으로 검색"
        }
    }
    
    var state: Bool {
        switch self {
        case .searchWithTitle:
            return UserDefaults.standard.bool(forKey: SearchFilterItem.searchWithTitle.rawValue)
        case .searchWithSinger:
            return UserDefaults.standard.bool(forKey: SearchFilterItem.searchWithSinger.rawValue)
        }
    }
    
    var userDefaultKey: String {
        switch self {
        case .searchWithTitle:
            return SearchFilterItem.searchWithTitle.rawValue
        case .searchWithSinger:
            return SearchFilterItem.searchWithSinger.rawValue
        }
    }
}
