//
//  HighlightingTextfield.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/07.
//

import UIKit
import RxSwift
import RxCocoa

class HighlightingTextfield: UITextField {
    // MARK: - Declaration
    private var disposeBag = DisposeBag()
    private static let cornerRadius: CGFloat = 12
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        initView()
        initEventListener()
    }
    
    private func initView() {
        self.layer.cornerRadius = HighlightingTextfield.cornerRadius
    }
    
    private func initEventListener() {
        self.rx.controlEvent(.editingDidBegin)
            .bind(onNext: { [weak self] in
                self?.hightlightTextField(ColorSet.accentColor)
            }).disposed(by: disposeBag)
        
        self.rx.controlEvent(.editingDidEnd)
            .bind(onNext: { [weak self] in
                self?.unhightlightTextField()
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Method
}

// MARK: - Extension
extension HighlightingTextfield {
    func hightlightTextField(_ color: UIColor) {
        layer.borderWidth = 1
        layer.borderColor = color.cgColor
    }
    
    func unhightlightTextField() {
        layer.borderWidth = 0
    }
}
