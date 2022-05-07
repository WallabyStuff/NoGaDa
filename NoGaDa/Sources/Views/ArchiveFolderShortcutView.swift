//
//  ArchiveShortcutView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/30.
//

import UIKit

class ArchiveFolderShortcutView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = ColorSet.archiveShortcutBackgroundColor
        layer.cornerRadius = 20
    }
}

extension ArchiveFolderShortcutView {
    
    var releaseAnimationDuration: CGFloat {
        return 0.3
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        backgroundColor = ColorSet.archiveShortcutSelectedBackgroundColor
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: releaseAnimationDuration) {
            self.backgroundColor = ColorSet.archiveShortcutBackgroundColor
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: releaseAnimationDuration) {
            self.backgroundColor = ColorSet.archiveShortcutBackgroundColor
        }
    }
}
