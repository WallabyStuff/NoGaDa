//
//  UIView+StatusBar.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/05/08.
//

import UIKit

extension UIView {
    func fillStatusBar(color: UIColor) {
        DispatchQueue.main.async {
            let safeAreaView = UIView()
            safeAreaView.backgroundColor = color
            self.insertSubview(safeAreaView, at: 0)
            safeAreaView.translatesAutoresizingMaskIntoConstraints = false
            safeAreaView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            safeAreaView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            safeAreaView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            safeAreaView.heightAnchor.constraint(equalToConstant: SafeAreaInsets.top).isActive = true
        }
    }
}
