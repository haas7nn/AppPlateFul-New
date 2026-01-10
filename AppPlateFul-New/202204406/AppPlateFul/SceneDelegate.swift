import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        // إنشاء النافذة
        let window = UIWindow(windowScene: windowScene)

        // تحميل Main.storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // تحديد أول ViewController (Initial View Controller)
        let initialVC = storyboard.instantiateInitialViewController()

        window.rootViewController = initialVC
        window.makeKeyAndVisible()

        self.window = window
    }
}
