//
//  AdminDashboardViewController.swift
//  AppPlateFul-New
//
//  Student ID: 202301686
//  Name: Hasan
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AdminDashboardViewController: UIViewController {

    // MARK: - IBOutlets

    // Action Card Buttons
    @IBOutlet weak var btn1: UIButton?
    @IBOutlet weak var btn2: UIButton?
    @IBOutlet weak var btn3: UIButton?
    @IBOutlet weak var btn5: UIButton?

    // Stats Labels
    @IBOutlet weak var pendingCountLabel: UILabel?
    @IBOutlet weak var donationsCountLabel: UILabel?
    @IBOutlet weak var usersCountLabel: UILabel?

    // Action Cards (for animations)
    @IBOutlet weak var actionCard1: UIView?
    @IBOutlet weak var actionCard2: UIView?
    @IBOutlet weak var actionCard3: UIView?
    @IBOutlet weak var actionCard4: UIView?

    // MARK: - Properties
    private let db = Firestore.firestore()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        loadStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadStats()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup

    private func setupUI() {
        let cards = [actionCard1, actionCard2, actionCard3, actionCard4]
        for card in cards {
            card?.isUserInteractionEnabled = true
            card?.layer.cornerRadius = 16
        }

        let buttons = [btn1, btn2, btn3, btn5]
        for button in buttons {
            button?.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
            button?.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        }
    }

    private func setupNavigationBar() {
        // Navigation bar is hidden, using custom header instead
    }

    // MARK: - Load Stats from Firebase

    private func loadStats() {
        loadPendingNGOsCount()
        loadDonationsCount()
        loadUsersCount()
    }

    private func loadPendingNGOsCount() {
        db.collection("ngoRequests")
            .whereField("status", isEqualTo: "pending")
            .getDocuments { [weak self] snapshot, _ in
                DispatchQueue.main.async {
                    let count = snapshot?.documents.count ?? 0
                    self?.pendingCountLabel?.text = "\(count)"
                    self?.animateLabel(self?.pendingCountLabel)
                }
            }
    }

    private func loadDonationsCount() {
        db.collection("donations")
            .getDocuments { [weak self] snapshot, _ in
                DispatchQueue.main.async {
                    let count = snapshot?.documents.count ?? 0
                    self?.donationsCountLabel?.text = self?.formatCount(count) ?? "0"
                    self?.animateLabel(self?.donationsCountLabel)
                }
            }
    }

    private func loadUsersCount() {
        db.collection("users")
            .getDocuments { [weak self] snapshot, _ in
                DispatchQueue.main.async {
                    let count = snapshot?.documents.count ?? 0
                    self?.usersCountLabel?.text = self?.formatCount(count) ?? "0"
                    self?.animateLabel(self?.usersCountLabel)
                }
            }
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            let formatted = Double(count) / 1000.0
            return String(format: "%.1fK", formatted)
        }
        return "\(count)"
    }

    private func animateLabel(_ label: UILabel?) {
        label?.alpha = 0
        label?.transform = CGAffineTransform(translationX: 0, y: 10)

        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            label?.alpha = 1
            label?.transform = .identity
        }
    }

    // MARK: - Button Animations

    @objc private func buttonTouchDown(_ sender: UIButton) {
        let card = sender.superview
        UIView.animate(withDuration: 0.1) {
            card?.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            card?.alpha = 0.9
        }
    }

    @objc private func buttonTouchUp(_ sender: UIButton) {
        let card = sender.superview
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5
        ) {
            card?.transform = .identity
            card?.alpha = 1
        }
    }

    // MARK: - IBActions

    @IBAction func pendingNGOsTapped(_ sender: UIButton) {
        openStoryboard(name: "NGOReview", identifier: nil)
    }

    @IBAction func donationActivityTapped(_ sender: UIButton) {
        openStoryboard(name: "DonationActivity", identifier: nil)
    }

    @IBAction func manageUsersTapped(_ sender: UIButton) {
        openStoryboard(name: "UserManagement", identifier: nil)
    }

    @IBAction func reportsTapped(_ sender: UIButton) {
        openStoryboard(name: "Reports", identifier: nil)
    }

    @IBAction func settingsTapped(_ sender: UIButton) {
        showComingSoon(feature: "Settings")
    }

    @IBAction func logoutTapped(_ sender: UIButton) {
        showLogoutConfirmation()
    }

    // MARK: - Navigation (FIXED)

    private func openStoryboard(name: String, identifier: String?) {
        let storyboard = UIStoryboard(name: name, bundle: nil)

        let loadedVC: UIViewController?
        if let id = identifier, !id.isEmpty {
            loadedVC = storyboard.instantiateViewController(withIdentifier: id)
        } else {
            loadedVC = storyboard.instantiateInitialViewController()
        }

        guard let firstVC = loadedVC else {
            showError("Could not load \(name) screen.\n\nMake sure the storyboard has an Initial View Controller set.")
            return
        }

        // ✅ If storyboard starts with a UINavigationController
        if let navFromStoryboard = firstVC as? UINavigationController {
            if let nav = navigationController {
                // can't push a nav controller, push its root instead
                if let root = navFromStoryboard.viewControllers.first {
                    nav.pushViewController(root, animated: true)
                } else {
                    showError("\(name) has a Navigation Controller but no root ViewController.")
                }
            } else {
                // present the navigation controller as-is
                navFromStoryboard.modalPresentationStyle = .fullScreen
                present(navFromStoryboard, animated: true)
            }
            return
        }

        // ✅ Normal case: storyboard starts with a regular VC
        if let nav = navigationController {
            nav.pushViewController(firstVC, animated: true)
        } else {
            let navVC = UINavigationController(rootViewController: firstVC)
            navVC.modalPresentationStyle = .fullScreen

            firstVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(dismissPresented)
            )

            present(navVC, animated: true)
        }
    }

    @objc private func dismissPresented() {
        dismiss(animated: true)
    }

    // MARK: - Logout

    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )

        let logoutAction = UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.performLogout()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(logoutAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

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
        UserDefaults.standard.synchronize()

        navigateToLogin()
    }

    private func navigateToLogin() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            dismiss(animated: true)
            return
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if let loginVC = storyboard.instantiateInitialViewController() {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()

            UIView.transition(
                with: window,
                duration: 0.4,
                options: .transitionCrossDissolve,
                animations: nil
            )
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Alerts

    private func showComingSoon(feature: String) {
        let alert = UIAlertController(
            title: "Coming Soon 🚀",
            message: "\(feature) will be available in a future update.",
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
