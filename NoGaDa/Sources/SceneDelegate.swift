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
        window?.rootViewController = mainViewController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    var mainViewController: UIViewController {
        let storyboard = UIStoryboard(name: R.storyboard.main.name, bundle: nil)
        let viewController = storyboard.instantiateViewController(identifier: MainViewController.identifier,
                                                                  creator: { coder -> MainViewController in
            let viewModel = MainViewModel()
            return .init(coder, viewModel) ?? MainViewController(viewModel)
        })
        
        return viewController
    }
}

