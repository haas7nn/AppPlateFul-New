import UIKit

final class AppNavigator {

    static let shared = AppNavigator()
    private init() {}

    // MARK: - Role-based navigation
    func navigate(user: User) {
        switch user.role {
        case .admin:
            setRoot(
                storyboard: "AdminDashboard",
                vcID: "AdminDashboardViewController"
            )

        case .ngo:
            setRoot(
                storyboard: "NgoFlow",
                vcID: "CollectorHomeViewController"
            )

        case .donor, .student:
            setRoot(
                storyboard: "DonorHome",
                vcID: "DonorHomeScreenViewController"
            )

        case .unknown:
            navigateToAuth()
        }
    }

    // MARK: - Auth navigation
    func navigateToAuth() {
        setRoot(
            storyboard: "Authentication",
            vcID: "AuthenticationNC"
        )
    }

    // MARK: - Root switch helper
    private func setRoot(storyboard: String, vcID: String) {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = scene.delegate as? SceneDelegate,
            let window = sceneDelegate.window
        else {
            print("❌ Failed to get window")
            return
        }

        let sb = UIStoryboard(name: storyboard, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: vcID)

        window.rootViewController = vc
        window.makeKeyAndVisible()
    }
}
