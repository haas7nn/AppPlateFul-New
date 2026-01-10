import UIKit
import FirebaseAuth

class CollectorHomeViewController: UIViewController {

    @IBOutlet weak var communityLeaderboardBtn: UIButton!
    @IBOutlet weak var updateDeliveryBtn: UIButton!
    @IBOutlet weak var collectorProfileBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!

    // MARK: - Actions

    @IBAction func communityLeaderboardTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Leaderboard", bundle: nil)
        
        guard let leaderboardVC = storyboard.instantiateInitialViewController() else {
            print("Could not instantiate initial view controller from Leaderboard.storyboard")
            return
        }
        
        navigationController?.pushViewController(leaderboardVC, animated: true)
    }
    
    
        @IBAction func updateDeliveryStatusTapped(_ sender: UIButton) {
            let storyboard = UIStoryboard(name: "DonationsList", bundle: nil)

            guard let donationsListRootVC = storyboard.instantiateInitialViewController() else {
                print("Could not instantiate initial view controller from DonationsList.storyboard")
                return
            }

            navigationController?.pushViewController(donationsListRootVC, animated: true)
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
