// AppPlateFul // 
// 202301686 - Hasan 
//




import UIKit

/// Central navigation manager responsible for switching the app flow
/// based on the authenticated user's role.
///
/// This class controls which storyboard becomes the app's root
/// after login (Admin, NGO, Donor, or Authentication).
final class AppNavigator {

    // MARK: - Singleton
    /// Shared instance used throughout the app.
    static let shared = AppNavigator()
    private init() {}

    // MARK: - Role-Based Navigation
    /// Routes the user to the correct app flow depending on their role.
    ///
    /// - Parameter user: The authenticated user object.
    func navigate(user: User) {
        switch user.role {

        case .admin:
            // Admin dashboard flow
            setRoot(
                storyboard: "AdminDashboard",
                vcID: "AdminDashboardViewController"
            )

        case .ngo:
            // NGO / collector flow
            setRoot(
                storyboard: "NgoFlow",
                vcID: "CollectorHomeViewController"
            )

        case .donor, .student:
            // Donor / student flow
            setRoot(
                storyboard: "AbdulwahedScreens",
                vcID: "DonorHomeScreenViewController"
            )

        case .unknown:
            // Fallback: user must authenticate
            navigateToAuth()
        }
    }

    // MARK: - Authentication Flow
    /// Sends the user to the authentication screens.
    func navigateToAuth() {
        setRoot(
            storyboard: "Authentication",
            vcID: "AuthenticationNC"
        )
    }

    // MARK: - Root Controller Switch
    /// Replaces the application's root view controller.
    ///
    /// This is used after login/logout to reset the navigation stack
    /// and prevent users from navigating back into restricted screens.
    private func setRoot(storyboard: String, vcID: String) {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = scene.delegate as? SceneDelegate,
            let window = sceneDelegate.window
        else {
            print("Failed to access application window")
            return
        }

        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: vcID)

        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}
