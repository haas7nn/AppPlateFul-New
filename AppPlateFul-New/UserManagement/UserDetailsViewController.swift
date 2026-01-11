//
//  UserDetailsViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Displays full details for a selected user (avatar, role, phone, email).
/// Also provides a "Call" action with a confirmation popup and copy-number option.
final class UserDetailsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var roleLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var callButton: UIButton!

    // MARK: - Data
    /// Injected from the previous screen (selected user).
    var user: User?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Makes the navigation bar transparent to match the design of this details screen.
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Restores default navigation bar appearance for other screens.
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }

    // MARK: - Setup
    private func setupUI() {
        // Avatar is displayed as a circle.
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true

        // Adds a subtle press animation to the call button (more responsive UX).
        callButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        callButton.addTarget(
            self,
            action: #selector(buttonTouchUp),
            for: [.touchUpInside, .touchUpOutside, .touchCancel]
        )
    }

    /// Populates the UI from the provided `user` model.
    /// Uses safe fallbacks for missing values (phone/email/avatar).
    private func populateData() {
        guard let user else { return }

        // Display-friendly properties provided by User model (computed properties).
        nameLabel.text = user.name
        roleLabel.text = user.roleText

        phoneLabel.text = user.phone ?? "No phone number"
        emailLabel.text = user.email ?? "No email"

        // Load avatar image if available; otherwise show a default icon.
        if let imageRef = user.imageRef, !imageRef.isEmpty {
            ImageLoader.shared.load(imageRef) { [weak self] image in
                DispatchQueue.main.async {
                    self?.avatarImageView.image =
                        image ?? UIImage(systemName: "person.circle.fill")
                }
            }
        } else {
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = UIColor(red: 0.4, green: 0.565, blue: 0.353, alpha: 1)
        }
    }

    // MARK: - Button Animation
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.callButton.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            self.callButton.alpha = 0.9
        }
    }

    @objc private func buttonTouchUp() {
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.5
        ) {
            self.callButton.transform = .identity
            self.callButton.alpha = 1
        }
    }

    // MARK: - Actions
    @IBAction private func callUserTapped(_ sender: UIButton) {
        showCallPopup()
    }

    // MARK: - Call Flow
    /// Shows a confirmation dialog before calling.
    /// Also allows copying the number for devices that cannot place calls.
    private func showCallPopup() {
        guard let phone = user?.phone, !phone.isEmpty else {
            showAlert(title: "No Phone", message: "This user doesn't have a phone number.")
            return
        }

        let userName = user?.name ?? "this user"

        let alert = UIAlertController(
            title: "📞 Call User",
            message: "Do you want to call \(userName)?\n\n\(phone)",
            preferredStyle: .alert
        )

        let callAction = UIAlertAction(title: "Call Now", style: .default) { [weak self] _ in
            self?.makePhoneCall(phone: phone)
        }

        let copyAction = UIAlertAction(title: "Copy Number", style: .default) { [weak self] _ in
            UIPasteboard.general.string = phone
            self?.showToast(message: "Phone number copied!")
        }

        alert.addAction(callAction)
        alert.addAction(copyAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }

    /// Attempts to open the system dialer using the "tel://" URL scheme.
    private func makePhoneCall(phone: String) {
        // Remove common formatting characters to build a valid tel URL.
        let cleanedPhone = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")

        if let url = URL(string: "tel://\(cleanedPhone)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Cannot Call", message: "Unable to make phone calls on this device.")
        }
    }

    // MARK: - Helpers
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /// Lightweight toast message shown at the bottom for quick feedback.
    private func showToast(message: String) {
        let toast = UILabel()
        toast.text = "  \(message)  "
        toast.textColor = .white
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toast.font = .systemFont(ofSize: 14, weight: .medium)
        toast.textAlignment = .center
        toast.layer.cornerRadius = 20
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            toast.heightAnchor.constraint(equalToConstant: 40)
        ])

        toast.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: {
                toast.alpha = 0
            }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
