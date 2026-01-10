import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class RegisterViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginTabButton: UIButton!
    @IBOutlet weak var registerTabButton: UIButton!
    @IBOutlet weak var cardView: UIView!

    private let db = Firestore.firestore()

    // Default role (change later if you add role selection UI)
    private let role: UserRole = .donor

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        registerButton.isUserInteractionEnabled = true
        registerButton.superview?.bringSubviewToFront(registerButton)
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

        styleTextField(nameTF, placeholder: "Full Name", icon: "person.fill")
        styleTextField(emailTF, placeholder: "Email", icon: "envelope.fill")
        styleTextField(passTF, placeholder: "Password", icon: "lock.fill")
        styleTextField(confirmTF, placeholder: "Confirm Password", icon: "lock.shield.fill")

        passTF.isSecureTextEntry = true
        confirmTF.isSecureTextEntry = true

        emailTF.autocapitalizationType = .none
        emailTF.autocorrectionType = .no
        passTF.autocapitalizationType = .none
        passTF.autocorrectionType = .no
        confirmTF.autocapitalizationType = .none
        confirmTF.autocorrectionType = .no

        registerButton.layer.cornerRadius = 16
        registerButton.layer.shadowColor = UIColor(red: 0.69, green: 0.77, blue: 0.61, alpha: 1).cgColor
        registerButton.layer.shadowOpacity = 0.4
        registerButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        registerButton.layer.shadowRadius = 8

        loginTabButton.layer.cornerRadius = 12
        registerTabButton.layer.cornerRadius = 12

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
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
    @IBAction func registerTapped(_ sender: UIButton) {
        animateButton(sender)

        let name = (nameTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let pass  = (passTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let conf  = (confirmTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty else { shakeRecognize(nameTF, "Please enter your name"); return }
        guard !email.isEmpty else { shakeRecognize(emailTF, "Please enter your email"); return }
        guard pass.count >= 6 else { shakeRecognize(passTF, "Password must be at least 6 characters"); return }
        guard conf == pass else { shakeRecognize(confirmTF, "Passwords do not match"); return }

        setLoading(true)

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

            // Match your User.swift parser expectations:
            // - displayName OR name (we write both to be safe)
            // - role must be lowercase: donor/ngo/admin
            // - status checked in AuthRouter
            // - createdAt used for joinDate formatting
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

                self.showAlert(title: "Done", message: "Account created successfully!") { [weak self] in
                    guard let self else { return }
                    AuthRouter.shared.routeAfterLogin(from: self)
                }
            }
        }
    }

    @IBAction func backToLoginTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Loading
    private func setLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            self.registerButton.isEnabled = !isLoading
            self.registerButton.alpha = isLoading ? 0.7 : 1.0
            self.view.isUserInteractionEnabled = !isLoading
        }
    }

    // MARK: - Animations
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) { button.transform = .identity }
        }
    }

    private func shakeRecognize(_ tf: UITextField, _ msg: String) {
        shakeTextField(tf)
        showAlert(title: "Oops!", message: msg)
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

    // MARK: - Alert
    private func showAlert(title: String, message: String, onOk: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in onOk?() })
            self.present(alert, animated: true)
        }
    }
}
