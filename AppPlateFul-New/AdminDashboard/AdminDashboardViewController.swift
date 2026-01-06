//
//  AdminDashboardViewController.swift
//  AppPlateFul
//
//  Student ID: 202301686
//  Name: Hasan
//

import UIKit

class AdminDashboardViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var btn1: UIButton?
    @IBOutlet weak var btn2: UIButton?
    @IBOutlet weak var btn3: UIButton?
    @IBOutlet weak var btn4: UIButton?
    @IBOutlet weak var btn5: UIButton?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCloseButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        let buttons = [btn1, btn2, btn3, btn4, btn5]
        for button in buttons {
            button?.layer.cornerRadius = 28
            button?.clipsToBounds = true
        }
    }
    
    // Adds a close button when the screen is presented modally
    private func setupCloseButton() {
        if presentingViewController != nil ||
            navigationController?.viewControllers.first == self {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Close",
                style: .done,
                target: self,
                action: #selector(closeTapped)
            )
        }
    }
    
    @objc private func closeTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    // MARK: - IBActions
    
    // Navigates to the Pending NGOs review screen
    @IBAction func pendingNGOsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NGOReview", bundle: nil)
        
        guard let listVC = storyboard.instantiateViewController(
            withIdentifier: "NGOReviewListViewController"
        ) as? NGOReviewListViewController else {
            showError("NGO Review screen not found")
            return
        }
        
        navigateTo(listVC)
    }
    
    // Navigates to the Donation Activity screen
    @IBAction func donationActivityTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "DonationActivity", bundle: nil)
        
        guard let donationVC = storyboard.instantiateViewController(
            withIdentifier: "DonationActivityViewController"
        ) as? DonationActivityViewController else {
            showError("Donation Activity screen not found")
            return
        }
        
        navigateTo(donationVC)
    }
    
    // Navigates to the User Management screen
    @IBAction func manageUsersTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "UserManagement", bundle: nil)
        
        guard let userListVC = storyboard.instantiateViewController(
            withIdentifier: "UserListViewController"
        ) as? UserListViewController else {
            showError("User Management screen not found")
            return
        }
        
        navigateTo(userListVC)
    }
    
    // Placeholder for future NGO management functionality
    @IBAction func manageNGOsTapped(_ sender: UIButton) {
        showComingSoon(feature: "Manage NGOs")
    }
    
    // Navigates to the Reports and Analytics screen
    @IBAction func reportsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Reports", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "ReportsAnalyticsViewController"
        )

        navigateTo(vc)
    }

    // MARK: - Navigation Helper
    private func navigateTo(_ viewController: UIViewController) {
        if let nav = navigationController {
            nav.pushViewController(viewController, animated: true)
        } else {
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            
            viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                title: "Back",
                style: .plain,
                target: self,
                action: #selector(dismissPresented)
            )
            
            present(navController, animated: true)
        }
    }
    
    @objc private func dismissPresented() {
        dismiss(animated: true)
    }
    
    // MARK: - Alerts
    private func showComingSoon(feature: String) {
        let alert = UIAlertController(
            title: "Coming Soon",
            message: "\(feature) feature will be available in a future update.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
