//
//  UserDefaultsManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2023/03/28.
//

import Foundation

struct UserDefaultsManager {
  
  enum Key: String {
    case searchBrand = "SEARCH_BRAND"
  }
  
  @UserDefaultEnum(key: "", defaultValue: .tj) static var searchBrand: KaraokeBrand
}
