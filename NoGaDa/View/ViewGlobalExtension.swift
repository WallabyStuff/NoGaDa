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
    func setSelectedTextColor(_ color: UIColor) {
        self.setTitleTextAttributes([.foregroundColor : color], for: .selected)
    }
    
    func setDefaultTextColor(_ color: UIColor) {
        self.setTitleTextAttributes([.foregroundColor : color], for: .normal)
    }
}

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
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.4
    }
    
    func setReversedExitButtonShadow() {
        self.layer.shadowColor = ColorSet.appbarBackgroundColor.cgColor
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = 20
        self.layer.shadowOpacity = 0.4
    }
    
    func setArchiveShortCutShadow() {
        self.layer.shadowColor = ColorSet.archiveShortcutShadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 8
        self.layer.shadowOpacity = 0.4
    }
    
    func setSongNumberBoxShadow() {
        self.layer.shadowColor = ColorSet.songCellNumberBoxShadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowRadius = 12
        self.layer.shadowOpacity = 1
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
        attributedString.addAttribute(.foregroundColor, value: ColorSet.textAccentColor,
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
        self.startAnimating()
        self.isHidden = false
    }
    
    func stopAnimatingAndHide() {
        self.isHidden = true
        self.stopAnimating()
    }
}

extension UIButton {
    func setPadding(width: CGFloat) {
        self.imageEdgeInsets = UIEdgeInsets(top: width, left: width, bottom: width, right: width)
    }
}

extension UITableView {
    func scrollToTopCell(animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.scrollToRow(at: indexPath, at: .top, animated: animated)
    }
}

extension UIScrollView {
    func scrollToTop(animated: Bool) {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: animated)
   }
}
