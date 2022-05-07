//
//  AppbarView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/28.
//

import UIKit
import Hero
import RxSwift
import RxCocoa

class AppbarHeight {
    static let shared = AppbarHeight()
    public var min: CGFloat = 80
    public var max: CGFloat = 140
    
    public func configure() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            AppbarHeight.shared.min = self.min + SafeAreaInsets.top
            AppbarHeight.shared.max = self.max + SafeAreaInsets.top
        }
    }
    
    private init() { }
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
