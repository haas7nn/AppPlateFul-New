import UIKit
import FirebaseAuth

class DonorHomeScreenViewController: UIViewController {

    // MARK: - Outlets (matching your existing names)
    @IBOutlet weak var CommunityLeaderBoard: UIButton!
    @IBOutlet weak var FavNGOS: UIButton!
    @IBOutlet weak var MyDonations: UIButton!
    @IBOutlet weak var TrackDeliveries: UIButton!
    @IBOutlet weak var DonationUpdates: UIButton!
    @IBOutlet weak var RecDonations: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Actions
    @IBAction func communityLeaderboardTapped(_ sender: UIButton) {
        // todo
    }

    @IBAction func favoriteNGOsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "FavoriteNGOs", bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: "FavoriteNGOsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func myDonationsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(
            name: "DonationSchedulingStoryboard",
            bundle: nil
        )

        let vc = storyboard.instantiateViewController(
            withIdentifier: "DonorSchedulingSide"
            
        )
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
       
    }

    @IBAction func trackDeliveriesTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "TrackingOrder", bundle: nil)

        guard let trackingRootVC = storyboard.instantiateInitialViewController() else {
            print("Could not instantiate initial view controller from TrackingOrder.storyboard")
            return
        }

        navigationController?.pushViewController(trackingRootVC, animated: true)
    }

    @IBAction func donationUpdatesTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonationsList", bundle: nil)

        guard let donationsListRootVC = storyboard.instantiateInitialViewController() else {
            print("Could not instantiate initial view controller from DonationsList.storyboard")
            return
        }

        navigationController?.pushViewController(donationsListRootVC, animated: true)
    }

    @IBAction func recurringDonationsTapped(_ sender: UIButton) {
        // todo
    }

    @IBAction func settingsTapped(_ sender: UIButton) {
        // todo
    }

    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
            } catch {
                print("Sign out failed: \(error.localizedDescription)")
            }

            UserDefaults.standard.removeObject(forKey: "isLoggedIn")
            UserDefaults.standard.removeObject(forKey: "currentUserEmail")
            UserDefaults.standard.removeObject(forKey: "currentUserRole")
            UserDefaults.standard.removeObject(forKey: "currentUserId")

            DispatchQueue.main.async {
                AppNavigator.shared.navigateToAuth()
            }
        })

        present(alert, animated: true)
    }
}
