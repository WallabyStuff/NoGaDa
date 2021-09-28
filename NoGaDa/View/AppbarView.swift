//
//  AppbarView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/28.
//

import UIKit
import Hero

enum AppbarHeight {
    static let minimum = 80 + SafeAreaInset.top
    static let maximum = 140 + SafeAreaInset.top
}

class AppbarView: UIView {
    
    private var _roundCorners: UIRectCorner = []
    private var _cornerRadius: CGFloat = 0
    private let maskLayer = CAShapeLayer()
    private let shadowLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure(cornerRadius: _cornerRadius, roundCorners: _roundCorners)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(cornerRadius: _cornerRadius, roundCorners: _roundCorners)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configure(cornerRadius: _cornerRadius, roundCorners: _roundCorners)
    }
    
    func configure(cornerRadius: CGFloat = 0, roundCorners: UIRectCorner = []) {
        hero.id = "appbar"
        
        _cornerRadius = cornerRadius
        _roundCorners = roundCorners
        
        // Mask the corner
        let path = UIBezierPath(roundedRect: frame,
                                byRoundingCorners: _roundCorners,
                                cornerRadii: CGSize(width: _cornerRadius, height: _cornerRadius))
        maskLayer.fillColor = ColorSet.appbarBackgroundColor.cgColor
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
        maskLayer.shadowColor = ColorSet.appbarBackgroundColor.cgColor
        maskLayer.shadowOffset = .zero
        maskLayer.shadowRadius = 2
        maskLayer.shadowOpacity = 0.2
        layer.insertSublayer(maskLayer, at: 0)
    }
}
