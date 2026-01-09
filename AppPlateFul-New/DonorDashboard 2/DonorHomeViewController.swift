//
//  DonorHomeViewController.swift
//  AppPlateFul
//

import UIKit

class DonorHomeViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var communityLeaderboardBtn: UIButton?
    @IBOutlet weak var favouriteNGOsBtn: UIButton?
    @IBOutlet weak var myDonationsBtn: UIButton?
    @IBOutlet weak var trackDeliveriesBtn: UIButton?
    @IBOutlet weak var donationUpdatesBtn: UIButton?
    @IBOutlet weak var recurringDonationsBtn: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("🚀 DonorHome viewDidLoad")
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup
    private func setupUI() {
        let buttons: [UIButton?] = [
            communityLeaderboardBtn,
            favouriteNGOsBtn,
            myDonationsBtn,
            trackDeliveriesBtn,
            donationUpdatesBtn,
            recurringDonationsBtn
        ]

        for button in buttons {
            button?.layer.cornerRadius = 28
            button?.clipsToBounds = true
        }
    }

    // MARK: - IBActions
    @IBAction func communityLeaderboardTapped(_ sender: UIButton) {
        print("📍 Community Leaderboard tapped")
        showComingSoon(feature: "Community Leaderboard")
    }

    @IBAction func favouriteNGOsTapped(_ sender: UIButton) {
        print("📍 Favourite NGOs tapped")

        let storyboard = UIStoryboard(name: "FavoriteNGOs", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FavoriteNGOsViewController")
        navigationController?.pushViewController(vc, animated: true)
    }

    // ✅ TEMP: My Donations goes to Organization Discovery (Find NGOs)
    @IBAction func myDonationsTapped(_ sender: UIButton) {
        let sb = UIStoryboard(name: "NgoOrginzationDiscovery", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OrganizationDiscoveryVC")
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func trackDeliveriesTapped(_ sender: UIButton) {
        print("📍 Track Deliveries tapped")
        showComingSoon(feature: "Track Deliveries")
    }

    @IBAction func donationUpdatesTapped(_ sender: UIButton) {
        print("📍 Donation Updates tapped")
        showComingSoon(feature: "Donation Updates")
    }

    @IBAction func recurringDonationsTapped(_ sender: UIButton) {
        print("📍 Recurring Donations tapped")
        showComingSoon(feature: "Recurring Donations")
    }

    // MARK: - Navigation helper
    private func pushOrganizationDiscovery() {
        let storyboard = UIStoryboard(name: "NgoOrginzationDiscovery", bundle: nil)

        // MUST match the Storyboard ID of OrganizationDiscoveryViewController
        let vc = storyboard.instantiateViewController(withIdentifier: "OrganizationDiscoveryVC")

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Helper
    private func showComingSoon(feature: String) {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "\(feature) feature coming soon!",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
