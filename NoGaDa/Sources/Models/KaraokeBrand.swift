//
//  KaraokeBrand.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/23.
//

import UIKit

enum KaraokeBrand: String, Codable, CaseIterable {
  case tj       = "tj"
  case kumyoung = "kumyoung"
  
  var path: String {
    switch self {
    case .tj:
      return "/tj.json"
    case .kumyoung:
      return "/kumyoung.json"
    }
  }
  
  var localizedString: String {
    switch self {
    case .tj:
      return "tj"
    case .kumyoung:
      return "금영"
    }
  }
}
