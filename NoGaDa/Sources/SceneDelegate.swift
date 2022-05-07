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
        AppbarHeight.shared.configure()
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
}

