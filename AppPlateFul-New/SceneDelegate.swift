//
//  SceneDelegate.swift
//  AppPlateFul-New
//
//  Created by Hassan Fardan on 06/01/2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Create window
        let window = UIWindow(windowScene: windowScene)

        // Load AdminDashboard storyboard
        let storyboard = UIStoryboard(name: "AdminDashboard", bundle: nil)

        // Instantiate AdminDashboardViewController
        let adminVC = storyboard.instantiateViewController(
            withIdentifier: "AdminDashboardViewController"
        )

        // Embed in navigation controller
        let navController = UINavigationController(rootViewController: adminVC)

        // Set root view controller
        window.rootViewController = navController
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
