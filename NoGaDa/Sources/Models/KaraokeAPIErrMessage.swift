//
//  KaraokeAPIErrMessage.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/23.
//

import UIKit

enum KaraokeAPIErrMessage: String, Error {
  case urlParsingError    = "Error: fail to parsing url string"
  case didNotReceiveData  = "Error: did not receive data"
  case httpRequestFailure = "Error: HTTP request failed"
  case jsonParsingError   = "Error: JSON Data Parsing failed"
}
