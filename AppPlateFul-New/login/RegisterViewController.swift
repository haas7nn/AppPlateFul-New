// AppPlateFul // 
// 202301686 - Hasan 
//


import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

/// Registration screen responsible for:
/// - collecting user info (name, email, password)
/// - validating inputs (empty fields, password rules)
/// - creating FirebaseAuth account
/// - saving the user profile in Firestore (users/{uid})
/// - routing to the correct app flow after success
final class RegisterViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var nameTF: UITextField!
    @IBOutlet private weak var emailTF: UITextField!
    @IBOutlet private weak var passTF: UITextField!
    @IBOutlet private weak var confirmTF: UITextField!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var loginTabButton: UIButton!
    @IBOutlet private weak var registerTabButton: UIButton!
    @IBOutlet private weak var cardView: UIView!

    // MARK: - Firebase
    private let db = Firestore.firestore()

    /// Default role for new accounts.
    /// If you later add role selection UI, this will come from the selected option.
    private let role: UserRole = .donor

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Safety: ensure the register button stays tappable above other views if needed.
        registerButton.isUserInteractionEnabled = true
        registerButton.superview?.bringSubviewToFront(registerButton)
    }

    /// Hides the navigation bar because the screen uses a custom header layout.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - UI Setup
    /// Applies styling to the card, text fields, and buttons.
    private func setupUI() {
        // Card styling (rounded + shadow)
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 12

        // Text fields (consistent look + icons)
        styleTextField(nameTF, placeholder: "Full Name", icon: "person.fill")
        styleTextField(emailTF, placeholder: "Email", icon: "envelope.fill")
        styleTextField(passTF, placeholder: "Password", icon: "lock.fill")
        styleTextField(confirmTF, placeholder: "Confirm Password", icon: "lock.shield.fill")

        // Password fields should hide text
        passTF.isSecureTextEntry = true
        confirmTF.isSecureTextEntry = true

        // Email/password inputs shouldn’t be auto-corrected or auto-capitalized
        emailTF.autocapitalizationType = .none
        emailTF.autocorrectionType = .no
        passTF.autocapitalizationType = .none
        passTF.autocorrectionType = .no
        confirmTF.autocapitalizationType = .none
        confirmTF.autocorrectionType = .no

        // Register button styling (rounded + subtle shadow)
        registerButton.layer.cornerRadius = 16
        registerButton.layer.shadowColor = UIColor(red: 0.69, green: 0.77, blue: 0.61, alpha: 1).cgColor
        registerButton.layer.shadowOpacity = 0.4
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        registerButton.layer.shadowRadius = 8

        // Tab buttons styling
        loginTabButton.layer.cornerRadius = 12
        registerTabButton.layer.cornerRadius = 12

        // Tap outside to dismiss keyboard (do not block button touches)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    /// Styles a text field with:
    /// - border + corner radius
    /// - placeholder color
    /// - left icon
    /// - right padding
    private func styleTextField(_ textField: UITextField, placeholder: String, icon: String) {
        textField.layer.cornerRadius = 14
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        textField.backgroundColor = .white
        textField.clipsToBounds = true

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 0.7, alpha: 1)]
        )

        let iconView = UIImageView(frame: CGRect(x: 12, y: 0, width: 20, height: 20))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor(red: 0.69, green: 0.77, blue: 0.61, alpha: 1)
        iconView.contentMode = .scaleAspectFit

        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        leftContainer.addSubview(iconView)

        textField.leftView = leftContainer
        textField.leftViewMode = .always

        // Padding on the right so text doesn’t touch the edge
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        textField.rightViewMode = .always
    }

    /// Dismisses the keyboard when user taps outside inputs.
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions
    /// Main registration flow:
    /// 1) validate inputs
    /// 2) create FirebaseAuth user
    /// 3) save user profile to Firestore
    /// 4) route using AuthRouter
    @IBAction private func registerTapped(_ sender: UIButton) {
        animateButton(sender)

        let name = (nameTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pass  = (passTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let conf  = (confirmTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // Local validation (fast feedback before network calls)
        guard !name.isEmpty else { shakeRecognize(nameTF, "Please enter your name"); return }
        guard !email.isEmpty else { shakeRecognize(emailTF, "Please enter your email"); return }
        guard pass.count >= 6 else { shakeRecognize(passTF, "Password must be at least 6 characters"); return }
        guard conf == pass else { shakeRecognize(confirmTF, "Passwords do not match"); return }

        setLoading(true)

        // Create account in Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: pass) { [weak self] result, error in
            guard let self else { return }

            if let error = error {
                self.setLoading(false)
                self.showAlert(title: "Register Failed", message: error.localizedDescription)
                return
            }

            guard let firebaseUser = result?.user else {
                self.setLoading(false)
                self.showAlert(title: "Error", message: "Missing user data")
                return
            }

            let uid = firebaseUser.uid

            // Save profile to Firestore using keys that the rest of the app expects.
            // Notes:
            // - role should be lowercase (donor/ngo/admin)
            // - status is checked later inside AuthRouter (active/inactive)
            // - createdAt helps with “join date” formatting and sorting
            let data: [String: Any] = [
                "uid": uid,
                "displayName": name,
                "name": name,
                "email": email,
                "role": self.role.rawValue.lowercased(),
                "status": "active",
                "createdAt": FieldValue.serverTimestamp()
            ]

            self.db.collection("users").document(uid).setData(data, merge: true) { [weak self] err in
                guard let self else { return }
                self.setLoading(false)

                if let err = err {
                    self.showAlert(title: "Save Failed", message: err.localizedDescription)
                    return
                }

                // After successful creation, route the user into the app.
                self.showAlert(title: "Done", message: "Account created successfully!") { [weak self] in
                    guard let self else { return }
                    AuthRouter.shared.routeAfterLogin(from: self)
                }
            }
        }
    }

    /// Returns to login screen (tab / back behavior).
    @IBAction private func backToLoginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Loading State
    /// Disables interactions while the registration network request is running.
    private func setLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            self.registerButton.isEnabled = !isLoading
            self.registerButton.alpha = isLoading ? 0.7 : 1.0
            self.view.isUserInteractionEnabled = !isLoading
        }
    }

    // MARK: - Animations & Feedback
    /// Simple press animation for nicer UI feedback.
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) { button.transform = .identity }
        }
    }

    /// Helper: shake the incorrect field and show a short message.
    private func shakeRecognize(_ tf: UITextField, _ msg: String) {
        shakeTextField(tf)
        showAlert(title: "Oops!", message: msg)
    }

    /// Shakes a field and highlights its border red for a moment.
    private func shakeTextField(_ textField: UITextField) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-10, 10, -8, 8, -5, 5, -2, 2, 0]
        textField.layer.add(animation, forKey: "shake")

        textField.layer.borderColor = UIColor.systemRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            textField.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        }
    }

    // MARK: - Alerts
    /// Displays an alert. Optional `onOk` lets us run an action after the user taps OK.
    private func showAlert(title: String, message: String, onOk: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOk?() })
            self.present(alert, animated: true)
        }
    }
}
