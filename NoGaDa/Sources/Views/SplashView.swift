//
//  SplashView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/14.
//

import UIKit

class SplashView: UIView {
  
  // MARK: - Declaration
  private let splashImageView = UIImageView()
  private let hideDelay: CGFloat = 0.3
  private let hideDuration: CGFloat = 0.3
  
  // MARK: - Methods
  func show(vc: UIViewController) {
    setupSplashView(vc: vc)
    setupSplashImageView(vc: vc)
  }
  
  func hide(_ completion: (() -> Void)?) {
    DispatchQueue.main.asyncAfter(deadline: .now() + hideDelay) {
      UIView.animate(withDuration: self.hideDuration) {
        self.alpha = 0
      } completion: { _ in
        completion?()
        self.removeFromSuperview()
      }
    }
  }
  
  private func setupSplashView(vc: UIViewController) {
    vc.view.addSubview(self)
    backgroundColor = R.color.splashBackgroundColor()
    translatesAutoresizingMaskIntoConstraints = false
    topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
    bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
    leadingAnchor.constraint(equalTo: vc.view.leadingAnchor).isActive = true
    trailingAnchor.constraint(equalTo: vc.view.trailingAnchor).isActive = true
  }
  
  private func setupSplashImageView(vc: UIViewController) {
    splashImageView.image = UIImage(named: "SplashImage")!
    addSubview(splashImageView)
    splashImageView.translatesAutoresizingMaskIntoConstraints = false
    splashImageView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
    splashImageView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor, constant: -36).isActive = true
    splashImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
    splashImageView.heightAnchor.constraint(equalTo: splashImageView.widthAnchor).isActive = true
  }
}
