//
//  ArchiveShortcutView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/30.
//

import UIKit

class ArchiveShortcutView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    private func configure() {
        backgroundColor = ColorSet.archiveShortcutBackgroundColor
        layer.cornerRadius = 20
        layer.shadowColor = ColorSet.archiveShortcutShadowColor.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.4
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = ColorSet.archiveShortcutSelectedBackgroundColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = ColorSet.archiveShortcutBackgroundColor
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        backgroundColor = ColorSet.archiveShortcutBackgroundColor
    }
}
