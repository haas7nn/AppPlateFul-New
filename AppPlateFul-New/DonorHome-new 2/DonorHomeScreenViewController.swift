import UIKit

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
        // Corner radius is now handled in storyboard via userDefinedRuntimeAttributes
        // You can remove these if using the new storyboard:
        // CommunityLeaderBoard.layer.cornerRadius = 10
        // FavNGOS.layer.cornerRadius = 10
        // MyDonations.layer.cornerRadius = 10
        // TrackDeliveries.layer.cornerRadius = 10
        // DonationUpdates.layer.cornerRadius = 10
        // RecDonations.layer.cornerRadius = 10
    }
    
    // MARK: - Actions
    @IBAction func communityLeaderboardTapped(_ sender: UIButton) {
        // Navigate to Community Leaderboard
        // let storyboard = UIStoryboard(name: "YourStoryboardName", bundle: nil)
        // let vc = storyboard.instantiateViewController(withIdentifier: "CommunityLeaderboardViewController")
        // navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func favoriteNGOsTapped(_ sender: UIButton) {
        // Navigate to Favorite NGOs
    }
    
    @IBAction func myDonationsTapped(_ sender: UIButton) {
        // Navigate to My Donations
    }
    
    @IBAction func trackDeliveriesTapped(_ sender: UIButton) {
        // Load the TrackingOrder storyboard
        let storyboard = UIStoryboard(name: "TrackingOrder", bundle: nil)
        
        // Instantiate its initial view controller
        guard let trackingRootVC = storyboard.instantiateInitialViewController() else {
            print("Could not instantiate initial view controller from TrackingOrder.storyboard")
            return
        }
        
        // Push onto the current navigation stack
        navigationController?.pushViewController(trackingRootVC, animated: true)
    }
    
    @IBAction func donationUpdatesTapped(_ sender: UIButton) {
        // Load the DonationsList storyboard (file name without .storyboard)
        let storyboard = UIStoryboard(name: "DonationsList", bundle: nil)
        
        // Instantiate its initial view controller
        guard let donationsListRootVC = storyboard.instantiateInitialViewController() else {
            print("Could not instantiate initial view controller from DonationsList.storyboard")
            return
        }
        
        // Push onto the current navigation stack
        navigationController?.pushViewController(donationsListRootVC, animated: true)
    }
    
    @IBAction func recurringDonationsTapped(_ sender: UIButton) {
        // Navigate to Recurring Donations
    }
    
    @IBAction func settingsTapped(_ sender: UIButton) {
        // Navigate to Settings
    }
    
    @IBAction func signOutTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            // Perform sign out and navigate to login
        })
        present(alert, animated: true)
    }
}
