import UIKit
import FirebaseAuth

class CollectorHomeViewController: UIViewController {

    @IBOutlet weak var communityLeaderboardBtn: UIButton!
    @IBOutlet weak var updateDeliveryBtn: UIButton!
    @IBOutlet weak var collectorProfileBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!

    // MARK: - Actions

    @IBAction func communityLeaderboardTapped(_ sender: UIButton) {
        // TODO: Navigate to leaderboard
    }

    @IBAction func updateDeliveryStatusTapped(_ sender: UIButton) {
        // TODO: Navigate to delivery status
    }

    @IBAction func collectorProfileTapped(_ sender: UIButton) {
        // TODO: Navigate to profile
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            self.performLogout()
        })

        present(alert, animated: true)
    }

    // MARK: - Logout Logic

    private func performLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Firebase sign out error: \(error.localizedDescription)")
        }

        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentUserEmail")
        UserDefaults.standard.removeObject(forKey: "currentUserRole")
        UserDefaults.standard.removeObject(forKey: "currentUserId")

        DispatchQueue.main.async {
            AppNavigator.shared.navigateToAuth()
        }
    }
}
