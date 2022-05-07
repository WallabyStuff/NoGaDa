//
//  UIView+Decorate.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/05/08.
//

import UIKit

extension UIView {
    func makeAsCircle() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    func setAppbarShadow() {
        self.layer.shadowColor = ColorSet.appbarBackgroundColor.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.4
    }
    
    func setSearchBoxShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 0.1
    }
    
    func setSearchBoxButtonShadow() {
        self.layer.shadowColor = ColorSet.appbarBackgroundColor.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.3
    }
    
    func setExitButtonShadow() {
        self.layer.shadowColor = ColorSet.appbarExitButtonBackgroundColor.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 16
        self.layer.shadowOpacity = 0.2
    }
    
    func setReversedExitButtonShadow() {
        self.layer.shadowColor = ColorSet.appbarBackgroundColor.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.4
    }
    
    func setSongNumberBoxShadow() {
        self.layer.shadowColor = ColorSet.songCellNumberBoxShadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 1
    }
    
    func makeAsSettingGroupView() {
        self.layer.cornerRadius = 20
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.1
    }
}
