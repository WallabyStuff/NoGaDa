//
//  ViewGlobalExtension.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit
import FloatingPanel

extension UITextField {
    func setPlaceholderColor(_ color: UIColor) {
        guard let placeholder = self.placeholder else { return }
        
        self.attributedPlaceholder = NSAttributedString(string: placeholder,
                                                        attributes: [NSAttributedString.Key.foregroundColor : color])
    }
    
    func setLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.frame.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UISegmentedControl {
    func setTextColor(color: UIColor) {
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : color], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.foregroundColor : color], for: .normal)
    }
}

extension UIView {
    func makeAsCircle() {
        self.layer.cornerRadius = self.frame.width / 2
    }
}

extension SurfaceAppearance {
    func setPanelShadow(color: UIColor) {
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = color
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        self.shadows = [shadow]
    }
}

extension UILabel {
    func setAccentColor(string: String) {
        guard let text = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: ColorSet.pointColor,
                                      range: (text.lowercased() as NSString).range(of: string.lowercased()))
        self.attributedText = attributedString
    }
    
    func releaseAccentColor() {
        guard let text = self.text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: ColorSet.textColor,
                                      range: (text as NSString).range(of: text))
        self.attributedText = attributedString
    }
}

extension UIActivityIndicatorView {
    func startAnimatingAndShow() {
        self.stopAnimating()
        self.isHidden = false
    }
    
    func stopAnimatingAndHide() {
        self.isHidden = true
        self.startAnimating()
    }
}

extension UIButton {
    func setPadding(width: CGFloat) {
        self.imageEdgeInsets = UIEdgeInsets(top: width, left: width, bottom: width, right: width)
    }
}
