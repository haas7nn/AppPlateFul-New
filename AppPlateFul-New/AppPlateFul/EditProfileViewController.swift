import UIKit
import FirebaseAuth

final class EditProfileViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var nameErr: UILabel!
    @IBOutlet weak var emailErr: UILabel!
    @IBOutlet weak var phoneErr: UILabel!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    // MARK: - Properties
    private let lightGreen = UIColor(named: "Light Green") ?? UIColor.systemGreen
    private let errorRed = UIColor.systemRed
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        hideErrors()
        loadUserData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleSaveButton()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "view")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTextFields() {
        [nameTF, emailTF, phoneTF].forEach { tf in
            guard let textField = tf else { return }
            textField.addTarget(self, action: #selector(handleBeginEditing(_:)), for: .editingDidBegin)
            textField.addTarget(self, action: #selector(handleEndEditing(_:)), for: .editingDidEnd)
            textField.addTarget(self, action: #selector(handleTextChange(_:)), for: .editingChanged)
        }
        
        emailTF.keyboardType = .emailAddress
        emailTF.autocapitalizationType = .none
        phoneTF.keyboardType = .phonePad
        nameTF.autocapitalizationType = .words
        
        nameTF.returnKeyType = .next
        emailTF.returnKeyType = .next
        phoneTF.returnKeyType = .done
        
        nameTF.delegate = self
        emailTF.delegate = self
        phoneTF.delegate = self
    }
    
    private func styleSaveButton() {
        saveBtn.layer.cornerRadius = 16
        saveBtn.layer.masksToBounds = false
        saveBtn.clipsToBounds = false
        
        saveBtn.layer.shadowColor = lightGreen.cgColor
        saveBtn.layer.shadowOpacity = 0.4
        saveBtn.layer.shadowRadius = 15
        saveBtn.layer.shadowOffset = CGSize(width: 0, height: 8)
        
        saveBtn.superview?.clipsToBounds = false
    }
    
    // MARK: - Error Handling
    private func hideErrors() {
        [nameErr, emailErr, phoneErr].forEach { label in
            label?.isHidden = true
            label?.alpha = 0
        }
        resetAllFieldStyles()
    }
    
    private func resetAllFieldStyles() {
        [nameTF, emailTF, phoneTF].forEach { resetFieldStyle($0) }
    }
    
    private func resetFieldStyle(_ tf: UITextField?) {
        guard let textField = tf, let container = textField.superview else { return }
        container.layer.borderWidth = 0
        container.layer.borderColor = UIColor.clear.cgColor
    }
    
    private func showError(for textField: UITextField, label: UILabel, message: String) {
        label.text = message
        label.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            label.alpha = 1
        }
        
        if let container = textField.superview {
            container.layer.borderWidth = 2
            container.layer.borderColor = errorRed.cgColor
            
            let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
            shake.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            shake.values = [-8, 8, -6, 6, -4, 4, 0]
            shake.duration = 0.5
            container.layer.add(shake, forKey: "shake")
        }
    }
    
    private func hideError(for textField: UITextField, label: UILabel) {
        UIView.animate(withDuration: 0.2) {
            label.alpha = 0
        } completion: { _ in
            label.isHidden = true
        }
        resetFieldStyle(textField)
    }
    
    // MARK: - Text Field Events
    @objc private func handleBeginEditing(_ textField: UITextField) {
        if let container = textField.superview {
            UIView.animate(withDuration: 0.2) {
                container.layer.borderWidth = 2
                container.layer.borderColor = self.lightGreen.cgColor
            }
        }
        
        if textField == nameTF { hideError(for: nameTF, label: nameErr) }
        if textField == emailTF { hideError(for: emailTF, label: emailErr) }
        if textField == phoneTF { hideError(for: phoneTF, label: phoneErr) }
    }
    
    @objc private func handleEndEditing(_ textField: UITextField) {
        if let container = textField.superview {
            UIView.animate(withDuration: 0.2) {
                container.layer.borderWidth = 0
                container.layer.borderColor = UIColor.clear.cgColor
            }
        }
        validateField(textField)
    }
    
    @objc private func handleTextChange(_ textField: UITextField) {
        if textField == nameTF && !nameErr.isHidden { hideError(for: nameTF, label: nameErr) }
        if textField == emailTF && !emailErr.isHidden { hideError(for: emailTF, label: emailErr) }
        if textField == phoneTF && !phoneErr.isHidden { hideError(for: phoneTF, label: phoneErr) }
    }
    
    private func validateField(_ textField: UITextField) {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if textField == nameTF && text.isEmpty {
            showError(for: nameTF, label: nameErr, message: "Please enter your full name")
        }
        
        if textField == emailTF {
            if text.isEmpty {
                showError(for: emailTF, label: emailErr, message: "Please enter your email address")
            } else if !isValidEmail(text) {
                showError(for: emailTF, label: emailErr, message: "Please enter a valid email address")
            }
        }
        
        if textField == phoneTF {
            if text.isEmpty {
                showError(for: phoneTF, label: phoneErr, message: "Please enter your phone number")
            } else if text.count != 8 {
                showError(for: phoneTF, label: phoneErr, message: "Phone number must be 8 digits")
            }
        }
    }
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPhone(_ phone: String) -> Bool {
        let digitsOnly = phone.filter { $0.isNumber }
        return digitsOnly.count == 8
    }
    
    // MARK: - Load User Data
    private func loadUserData() {
        if let user = Auth.auth().currentUser {
            emailTF.text = user.email
            nameTF.text = user.displayName
        }
    }
    
    // MARK: - Save Action
    @IBAction func didTapSave(_ sender: UIButton) {
        dismissKeyboard()
        hideErrors()
        
        let name = (nameTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let email = (emailTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let phone = (phoneTF.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        var isValid = true
        
        if name.isEmpty {
            showError(for: nameTF, label: nameErr, message: "Please enter your full name")
            isValid = false
        }
        
        if email.isEmpty {
            showError(for: emailTF, label: emailErr, message: "Please enter your email address")
            isValid = false
        } else if !isValidEmail(email) {
            showError(for: emailTF, label: emailErr, message: "Please enter a valid email address")
            isValid = false
        }
        
        if phone.isEmpty {
            showError(for: phoneTF, label: phoneErr, message: "Please enter your phone number")
            isValid = false
        } else if !isValidPhone(phone) {
            showError(for: phoneTF, label: phoneErr, message: "Phone number must be 8 digits")
            isValid = false
        }
        
        guard isValid else { return }
        
        saveBtn.isEnabled = false
        saveBtn.alpha = 0.7
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.saveBtn.isEnabled = true
            self?.saveBtn.alpha = 1.0
            self?.showSuccessAlert()
        }
    }
    
    private func showSuccessAlert() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let alert = UIAlertController(
            title: "Success! ✅",
            message: "Your profile has been updated successfully.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTF {
            emailTF.becomeFirstResponder()
        } else if textField == emailTF {
            phoneTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            didTapSave(saveBtn)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneTF {
            let currentText = textField.text ?? ""
            let newLength = currentText.count + string.count - range.length
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet) && newLength <= 8
        }
        return true
    }
}
