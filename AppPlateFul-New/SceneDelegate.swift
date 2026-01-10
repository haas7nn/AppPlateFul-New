import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()

        if Auth.auth().currentUser != nil {
            AuthRouter.shared.routeAfterLogin(from: window.rootViewController ?? UIViewController())
        } else {
            AppNavigator.shared.navigateToAuth()
        }
    }
}
