//
//  AnimateButton.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/08/28.
//

import UIKit

class AnimateButton: UIButton {
  
  
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
    setupTargets()
  }
  
  private func setupTargets() {
    self.addTarget(self, action: #selector(didTapButton(_:)), for: .touchDown)
    self.addTarget(self, action: #selector(didTapRelease(_:)), for: [.touchCancel, .touchDragExit])
  }
  
  
  // MARK: - Methods
  
  @objc func didTapButton(_ sender: Any) {
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
      self.scaleDown()
    }
  }
  
  @objc func didTapRelease(_ sender: Any) {
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
      self.releaseScale()
    }
  }
}
