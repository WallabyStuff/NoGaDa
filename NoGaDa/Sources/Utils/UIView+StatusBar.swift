//
//  UIView+StatusBar.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/06/14.
//

import UIKit

extension UIView {
  func fillStatusBar(color: UIColor) {
    let safeAreaView = UIView()
    safeAreaView.backgroundColor = color
    
    self.insertSubview(safeAreaView, at: 0)
    safeAreaView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      safeAreaView.topAnchor.constraint(equalTo: self.topAnchor),
      safeAreaView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      safeAreaView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      safeAreaView.heightAnchor.constraint(equalToConstant: AppbarHeight.safeAreaTop)
    ])
  }
}
