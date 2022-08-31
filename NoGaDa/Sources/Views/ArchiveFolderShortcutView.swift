//
//  ArchiveShortcutView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/30.
//

import UIKit

class ArchiveFolderShortcutView: AnimateView {
  
  
  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    backgroundColor = R.color.archiveShortcutBackgroundColor()
    layer.cornerRadius = 20
  }
}

extension ArchiveFolderShortcutView {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
      self.backgroundColor = R.color.archiveShortcutSelectedBackgroundColor()
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    UIView.animate(withDuration: 0.3) {
      self.backgroundColor = R.color.archiveShortcutBackgroundColor()
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    UIView.animate(withDuration: 0.3) {
      self.backgroundColor = R.color.archiveShortcutBackgroundColor()
    }
  }
}
