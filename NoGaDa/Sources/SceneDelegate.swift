//
//  SceneDelegate.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = splashViewController
    window?.makeKeyAndVisible()
  }
}

extension SceneDelegate {
  private var splashViewController: UIViewController {
    let viewController = SplashViewController()
    return viewController
  }
}
