//
//  ProfileViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

final class ProfileViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var emailValueLabel: UILabel!
    @IBOutlet weak var phoneValueLabel: UILabel!
    @IBOutlet weak var memberSinceLabel: UILabel!

    // MARK: - Properties
    private var userProfile: UserProfile?
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
        profileListener?.remove()

        ProfileService.shared.ensureProfileExists { [weak self] result in
            switch result {
            case .success:
                self?.profileListener = ProfileService.shared.listenForProfileChanges { [weak self] result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let profile):
                            self?.userProfile = profile
                            self?.updateUI(with: profile)
                        case .failure(let error):
                            self?.showError(error.localizedDescription)
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }

    private func updateUI(with profile: UserProfile) {
        nameLabel.text = profile.displayName
        emailLabel.text = profile.email

        if let systemImage = UIImage(systemName: profile.profileImageName) {
            avatarImageView.image = systemImage
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
        }

        nameValueLabel.text = profile.displayName
        emailValueLabel.text = profile.email
        phoneValueLabel.text = profile.phone.isEmpty ? "Not set" : profile.phone
        memberSinceLabel.text = profile.memberSinceFormatted
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true)
        }
    }

    @IBAction func editProfileTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showEditProfile", sender: nil)
    }

    @IBAction func settingsTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showSettings", sender: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEditProfile",
           let editVC = segue.destination as? EditProfileViewController {
            editVC.userProfile = userProfile
        } else if segue.identifier == "showSettings",
                  let settingsVC = segue.destination as? SettingsViewController {
            settingsVC.userProfile = userProfile
        }
    }
}
