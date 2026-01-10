//
//  SettingsViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

final class SettingsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!

    // MARK: - Properties
    var userProfile: UserProfile?
    private var profileListener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadUserProfile()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        profileListener?.remove()
    }

    // MARK: - Setup
    private func setupUI() {
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.tintColor = .white
    }

    // MARK: - Data Loading
    private func loadUserProfile() {
        if let profile = userProfile {
            updateUI(with: profile)
        }

        profileListener?.remove()

        ProfileService.shared.ensureProfileExists { [weak self] _ in
            self?.profileListener = ProfileService.shared.listenForProfileChanges { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self?.userProfile = profile
                        self?.updateUI(with: profile)
                    case .failure:
                        break
                    }
                }
            }
        }
    }

    private func updateUI(with profile: UserProfile) {
        nameLabel.text = profile.displayName
        statusLabel.text = profile.status.capitalized

        if let systemImage = UIImage(systemName: profile.profileImageName) {
            avatarImageView.image = systemImage
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }

    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func editProfileTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showEditProfileFromSettings", sender: nil)
    }

    @IBAction func notificationsTapped(_ sender: UIButton) {
        navigateToNotifications()
    }

    @IBAction func faqTapped(_ sender: UIButton) {
        navigateToFAQ()
    }

    @IBAction func privacyPolicyTapped(_ sender: UIButton) {
        navigateToPrivacyPolicy()
    }

    @IBAction func termsConditionsTapped(_ sender: UIButton) {
        navigateToTermsConditions()
    }

    // MARK: - Navigation Methods
    private func navigateToNotifications() {
        if let vc = UIStoryboard(name: "Notification", bundle: nil).instantiateInitialViewController() {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            showComingSoonAlert(for: "Notification")
        }
    }

    private func navigateToFAQ() {
        if let vc = UIStoryboard(name: "FAQ", bundle: nil).instantiateInitialViewController() {
            if let nav = vc as? UINavigationController,
               let root = nav.viewControllers.first {
                navigationController?.pushViewController(root, animated: true)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            showComingSoonAlert(for: "FAQ")
        }
    }

    private func navigateToPrivacyPolicy() {
        if let vc = UIStoryboard(name: "PrivacyPolicy", bundle: nil).instantiateInitialViewController() {
            if let nav = vc as? UINavigationController,
               let root = nav.viewControllers.first {
                navigationController?.pushViewController(root, animated: true)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            showComingSoonAlert(for: "Privacy Policy")
        }
    }

    private func navigateToTermsConditions() {
        if let vc = UIStoryboard(name: "TermsAndCon", bundle: nil).instantiateInitialViewController() {
            if let nav = vc as? UINavigationController,
               let root = nav.viewControllers.first {
                navigationController?.pushViewController(root, animated: true)
            } else {
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            showComingSoonAlert(for: "Terms & Conditions")
        }
    }

    private func showComingSoonAlert(for feature: String) {
        let alert = UIAlertController(title: feature, message: "This feature is coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditProfileFromSettings",
           let editVC = segue.destination as? EditProfileViewController {
            editVC.userProfile = userProfile
        }
    }
}
