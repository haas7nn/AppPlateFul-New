//
//  EditProfileViewController.swift
//  AppPlateFul
//

import UIKit

class EditProfileViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailDisplayLabel: UILabel!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var userProfile: UserProfile?
    
    private let primaryGreen = UIColor(red: 0.256, green: 0.573, blue: 0.166, alpha: 1.0)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Text field delegates
        nameField.delegate = self
        phoneField.delegate = self
        
        // Hide error labels initially
        nameErrorLabel.isHidden = true
        phoneErrorLabel.isHidden = true
        
        // Add text change listeners
        nameField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        phoneField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func populateFields() {
        guard let profile = userProfile else { return }
        
        // Avatar
        if let systemImage = UIImage(systemName: profile.profileImageName) {
            avatarImageView.image = systemImage
        }
        
        // Fields
        nameField.text = profile.displayName
        emailDisplayLabel.text = profile.email
        phoneField.text = profile.phone
    }
    
    // MARK: - Validation
    private func validateName() -> Bool {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showNameError("Name is required")
            return false
        }
        
        if name.count < 2 {
            showNameError("Name must be at least 2 characters")
            return false
        }
        
        hideNameError()
        return true
    }
    
    private func validatePhone() -> Bool {
        guard let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            hidePhoneError()
            return true // Phone is optional
        }
        
        if phone.isEmpty {
            hidePhoneError()
            return true
        }
        
        // Basic phone validation (adjust regex as needed)
        let phoneRegex = "^[+]?[0-9\\s-]{8,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        if !phonePredicate.evaluate(with: phone) {
            showPhoneError("Invalid phone number format")
            return false
        }
        
        hidePhoneError()
        return true
    }
    
    private func showNameError(_ message: String) {
        nameErrorLabel.text = message
        nameErrorLabel.isHidden = false
    }
    
    private func hideNameError() {
        nameErrorLabel.isHidden = true
    }
    
    private func showPhoneError(_ message: String) {
        phoneErrorLabel.text = message
        phoneErrorLabel.isHidden = false
    }
    
    private func hidePhoneError() {
        phoneErrorLabel.isHidden = true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == nameField {
            _ = validateName()
        } else if textField == phoneField {
            _ = validatePhone()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        dismissKeyboard()
        
        // Validate all fields
        let isNameValid = validateName()
        let isPhoneValid = validatePhone()
        
        guard isNameValid && isPhoneValid else {
            return
        }
        
        // Get values
        guard let name = nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        let phone = phoneField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // Show loading
        setLoading(true)
        
        // Update profile
        ProfileService.shared.updateUserProfile(displayName: name, phone: phone) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoading(false)
                
                switch result {
                case .success:
                    self?.showSuccessAndPop()
                case .failure(let error):
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }
    
    private func setLoading(_ loading: Bool) {
        saveButton.isEnabled = !loading
        saveButton.alpha = loading ? 0.6 : 1.0
        
        if loading {
            loadingIndicator.startAnimating()
            saveButton.setTitle("Saving...", for: .normal)
        } else {
            loadingIndicator.stopAnimating()
            saveButton.setTitle("Save Changes", for: .normal)
        }
    }
    
    private func showSuccessAndPop() {
        let alert = UIAlertController(title: "Success", message: "Your profile has been updated.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            phoneField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
