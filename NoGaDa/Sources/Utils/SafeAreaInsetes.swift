//
//  UIView+SafeAreaInsets.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/05/08.
//

import UIKit

class SafeAreaInsets {
    static var top: CGFloat {
        if let window = UIApplication.shared.keyWindow {
            return window.safeAreaInsets.top
        } else {
            return 0
        }
    }
    
    static var bottom: CGFloat {
        if let window = UIApplication.shared.keyWindow {
            return window.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
    
    static var left: CGFloat {
        if let window = UIApplication.shared.keyWindow {
            return window.safeAreaInsets.left
        } else {
            return 0
        }
    }
    
    static var right: CGFloat {
        if let window = UIApplication.shared.keyWindow {
            return window.safeAreaInsets.right
        } else {
            return 0
        }
    }
}
