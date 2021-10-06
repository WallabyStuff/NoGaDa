//
//  ReviewRequestManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/07.
//

import UIKit
import StoreKit

class ReviewRequestManager {
    
    static func requestReview() {
        if let windowScene = UIApplication.shared.windows.first?.windowScene {
            if #available(iOS 14.0, *) {
                SKStoreReviewController.requestReview(in: windowScene)
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }
}
