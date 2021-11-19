//
//  SplashView.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/14.
//

import UIKit

class SplashView: UIView {
    
    let splashImageView = UIImageView()
    
    func show(vc: UIViewController) {
        configureSplashView(vc: vc)
        addSplashImageView(vc: vc)
    }
    
    func hide() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0
            } completion: { isCompleted in
                if isCompleted {
                    self.removeFromSuperview()
                }
            }
        }
    }
    
    private func configureSplashView(vc: UIViewController) {
        vc.view.addSubview(self)
        backgroundColor = ColorSet.splashBackgroundColor
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: vc.view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: vc.view.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: vc.view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: vc.view.trailingAnchor).isActive = true
    }
    
    private func addSplashImageView(vc: UIViewController) {
        splashImageView.image = UIImage(named: "SplashImage")!
        addSubview(splashImageView)
        splashImageView.translatesAutoresizingMaskIntoConstraints = false
        splashImageView.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor).isActive = true
        splashImageView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        splashImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        splashImageView.heightAnchor.constraint(equalTo: splashImageView.widthAnchor).isActive = true
    }
}
