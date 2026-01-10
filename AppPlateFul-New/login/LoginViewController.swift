import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerTabButton: UIButton!
    @IBOutlet weak var loginTabButton: UIButton!
    @IBOutlet weak var cardView: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    // MARK: - Setup UI
    private func setupUI() {
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardView.layer.shadowRadius = 12

        styleTextField(emailTF, placeholder: "Email", icon: "envelope.fill")
        styleTextField(passTF, placeholder: "Password", icon: "lock.fill")
        passTF.isSecureTextEntry = true

        emailTF.autocapitalizationType = .none
        emailTF.autocorrectionType = .no
        passTF.autocapitalizationType = .none
        passTF.autocorrectionType = .no

        loginButton.layer.cornerRadius = 16

        loginTabButton.layer.cornerRadius = 12
        registerTabButton.layer.cornerRadius = 12

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

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

        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 20))
        textField.rightViewMode = .always
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - IBActions
    @IBAction func loginTapped(_ sender: UIButton) {
        animateButton(sender)

        let email = (emailTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passTF.text ?? ""

        guard !email.isEmpty, !password.isEmpty else {
            shakeTextField(email.isEmpty ? emailTF : passTF)
            showAlert(title: "Oops!", message: "Please fill in all fields")
            return
        }

        sender.isEnabled = false

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self else { return }

            DispatchQueue.main.async {
                sender.isEnabled = true
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "Login Failed", message: error.localizedDescription)
                }
                return
            }

            // ✅ This is the only line you need after successful login:
            AuthRouter.shared.routeAfterLogin(from: self)
        }
    }

    // MARK: - Animations
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }

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

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
