//
//  AddReviewViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

protocol AddReviewDelegate: AnyObject {
    func didAddReview(name: String, rating: Int, comment: String)
}

class AddReviewViewController: UIViewController {

    private let db = Firestore.firestore()

    // MARK: - UI Elements
    private let containerView = UIView()
    private let handleView = UIView()
    private let titleLabel = UILabel()
    private let ngoLabel = UILabel()
    private let nameTextField = UITextField()
    private let ratingLabel = UILabel()
    private let ratingStackView = UIStackView()
    private var starButtons: [UIButton] = []
    private let commentTextView = UITextView()
    private let placeholderLabel = UILabel()
    private let submitButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    weak var delegate: AddReviewDelegate?

    var ngoName: String = ""
    var ngoId: String = ""
    private var selectedRating: Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupGestures()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Handle
        handleView.backgroundColor = UIColor.systemGray4
        handleView.layer.cornerRadius = 2.5
        handleView.translatesAutoresizingMaskIntoConstraints = false

        // Container
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 24
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        containerView.addSubview(handleView)

        // Title
        titleLabel.text = "Write a Review"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        // NGO Label
        ngoLabel.text = "for \(ngoName)"
        ngoLabel.font = .systemFont(ofSize: 15)
        ngoLabel.textAlignment = .center
        ngoLabel.textColor = .systemGray
        ngoLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ngoLabel)

        // Name Field
        nameTextField.placeholder = "Your Name"
        nameTextField.borderStyle = .none
        nameTextField.backgroundColor = UIColor(white: 0.96, alpha: 1)
        nameTextField.layer.cornerRadius = 14
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.font = .systemFont(ofSize: 16)
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameTextField)

        // Rating Label
        ratingLabel.text = "Your Rating"
        ratingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratingLabel)

        // Rating Stack
        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 12
        ratingStackView.distribution = .fillEqually
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratingStackView)

        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.tag = i
            starButton.titleLabel?.font = .systemFont(ofSize: 36)
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(starButton)
            ratingStackView.addArrangedSubview(starButton)
        }
        updateStarDisplay()

        // Comment TextView
        commentTextView.font = .systemFont(ofSize: 16)
        commentTextView.backgroundColor = UIColor(white: 0.96, alpha: 1)
        commentTextView.layer.cornerRadius = 14
        commentTextView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 12)
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.delegate = self
        containerView.addSubview(commentTextView)

        // Placeholder
        placeholderLabel.text = "Share your experience..."
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.addSubview(placeholderLabel)

        // Submit Button
        submitButton.setTitle("Submit Review", for: .normal)
        submitButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        submitButton.backgroundColor = UIColor(red: 0.73, green: 0.80, blue: 0.63, alpha: 1.0)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 14
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(submitButton)
        
        // Loading Indicator
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addSubview(loadingIndicator)

        // Cancel Button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemGray, for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)
        
        // Shadow
        submitButton.layer.shadowColor = UIColor(red: 0.204, green: 0.780, blue: 0.349, alpha: 1).cgColor
        submitButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        submitButton.layer.shadowRadius = 8
        submitButton.layer.shadowOpacity = 0.3
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            handleView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 40),
            handleView.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            ngoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            ngoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            ngoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            nameTextField.topAnchor.constraint(equalTo: ngoLabel.bottomAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            nameTextField.heightAnchor.constraint(equalToConstant: 52),

            ratingLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            ratingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),

            ratingStackView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 12),
            ratingStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            ratingStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            ratingStackView.heightAnchor.constraint(equalToConstant: 50),

            commentTextView.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 24),
            commentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            commentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            commentTextView.heightAnchor.constraint(equalToConstant: 130),

            placeholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 14),
            placeholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 16),

            submitButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 24),
            submitButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            submitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            submitButton.heightAnchor.constraint(equalToConstant: 54),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: submitButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: submitButton.centerYAnchor),

            cancelButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 12),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24),
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleBackgroundTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !containerView.frame.contains(location) {
            cancelTapped()
        }
    }

    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarDisplay()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func updateStarDisplay() {
        for (index, button) in starButtons.enumerated() {
            let isFilled = index < selectedRating
            button.setTitle(isFilled ? "★" : "☆", for: .normal)
            button.tintColor = isFilled ? UIColor(red: 1, green: 0.8, blue: 0, alpha: 1) : .systemGray3
            
            UIView.animate(withDuration: 0.15) {
                button.transform = isFilled ? CGAffineTransform(scaleX: 1.1, y: 1.1) : .identity
            }
        }
    }

    @objc private func submitTapped() {
        guard !ngoId.isEmpty else {
            showAlert(message: "NGO not found.")
            return
        }

        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            shakeTextField(nameTextField)
            return
        }

        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !comment.isEmpty else {
            showAlert(message: "Please write your review.")
            return
        }
        
        setLoading(true)

        let data: [String: Any] = [
            "name": name,
            "rating": selectedRating,
            "comment": comment,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("ngo_reviews")
            .document(ngoId)
            .collection("reviews")
            .addDocument(data: data) { [weak self] error in
                self?.setLoading(false)

                if let error = error {
                    self?.showAlert(message: error.localizedDescription)
                    return
                }

                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                
                self?.delegate?.didAddReview(name: name, rating: self?.selectedRating ?? 5, comment: comment)
                self?.dismiss(animated: true)
            }
    }
    
    private func setLoading(_ loading: Bool) {
        submitButton.isEnabled = !loading
        
        if loading {
            submitButton.setTitle("", for: .normal)
            loadingIndicator.startAnimating()
        } else {
            submitButton.setTitle("Submit Review", for: .normal)
            loadingIndicator.stopAnimating()
        }
    }
    
    private func shakeTextField(_ textField: UITextField) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.5
        animation.values = [-10, 10, -8, 8, -5, 5, -3, 3, 0]
        textField.layer.add(animation, forKey: "shake")
        
        let originalBg = textField.backgroundColor
        UIView.animate(withDuration: 0.2) {
            textField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.3) {
                textField.backgroundColor = originalBg
            }
        }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Oops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension AddReviewViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}
