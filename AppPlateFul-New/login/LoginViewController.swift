// AppPlateFul // 
// 202301686 - Hasan 
//


import UIKit
import FirebaseAuth

/// Login screen responsible for:
/// 1) collecting user credentials
/// 2) validating inputs
/// 3) calling FirebaseAuth sign-in
/// 4) handing off routing to AuthRouter after success
final class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var emailTF: UITextField!
    @IBOutlet private weak var passTF: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerTabButton: UIButton!
    @IBOutlet private weak var loginTabButton: UIButton!
    @IBOutlet private weak var cardView: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    /// Hides the navigation bar because this screen has its own custom header design.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - UI Setup
    /// Applies styling for the login card, text fields, and buttons.
    private func setupUI() {
        // Card container styling (rounded + shadow)
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 12

        // Text fields (consistent styling)
        styleTextField(emailTF, placeholder: "Email", icon: "envelope.fill")
        styleTextField(passTF, placeholder: "Password", icon: "lock.fill")
        passTF.isSecureTextEntry = true

        // Disable autocorrect/caps to avoid login input issues
        emailTF.autocapitalizationType = .none
        emailTF.autocorrectionType = .no
        passTF.autocapitalizationType = .none
        passTF.autocorrectionType = .no

        // Buttons styling
        loginButton.layer.cornerRadius = 16
        loginTabButton.layer.cornerRadius = 12
        registerTabButton.layer.cornerRadius = 12

        // Tap outside to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        view.addGestureRecognizer(tapGesture)
    }

    /// Styles a text field with borders + placeholder + left icon.
    private func styleTextField(_ textField: UITextField,
                                placeholder: String,
                                icon: String) {

        textField.layer.cornerRadius = 14
        textField.layer.borderWidth = 1.5
        textField.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
        textField.backgroundColor = .white
        textField.clipsToBounds = true

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: UIColor(white: 0.7, alpha: 1)]
        )

        // Left icon container
        let iconView = UIImageView(frame: CGRect(x: 12, y: 0, width: 20, height: 20))
        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = UIColor(red: 0.69, green: 0.77, blue: 0.61, alpha: 1)
        iconView.contentMode = .scaleAspectFit

        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 20))
        leftContainer.addSubview(iconView)

        textField.leftView = leftContainer
        textField.leftViewMode = .always

        // Right padding so text doesn't hit the edge
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        textField.rightViewMode = .always
    }

    /// Dismisses keyboard when the user taps outside input fields.
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Actions
    /// Validates inputs and attempts FirebaseAuth sign-in.
    /// On success, routing is handled by AuthRouter.
    @IBAction private func loginTapped(_ sender: UIButton) {
        animateButton(sender)

        let email = (emailTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passTF.text ?? ""

        // Basic validation: no empty fields
        guard !email.isEmpty, !password.isEmpty else {
            shakeTextField(email.isEmpty ? emailTF : passTF)
            showAlert(title: "Oops!", message: "Please fill in all fields")
            return
        }

        // Prevent multiple taps while request is running
        sender.isEnabled = false

        // Firebase authentication
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self else { return }

            // Re-enable the button regardless of result
            DispatchQueue.main.async {
                sender.isEnabled = true
            }

            // Show error to user if sign-in failed
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
                return
            }

            // After Auth success, verify role + status in Firestore and route accordingly
            AuthRouter.shared.routeAfterLogin(from: self)
        }
    }

    // MARK: - Animations & Feedback
    /// Simple press animation for better button feedback.
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }

    /// Shakes the given text field and temporarily highlights its border red.
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

    /// Shows a basic alert message.
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
