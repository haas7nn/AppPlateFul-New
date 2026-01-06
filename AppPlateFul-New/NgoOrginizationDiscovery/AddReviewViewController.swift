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

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let nameTextField = UITextField()
    private let ratingLabel = UILabel()
    private let ratingStackView = UIStackView()
    private var starButtons: [UIButton] = []
    private let commentTextView = UITextView()
    private let submitButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    weak var delegate: AddReviewDelegate?

    var ngoName: String = ""
    var ngoId: String = ""          // 🔥 REQUIRED
    private var selectedRating: Int = 5

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)

        titleLabel.text = "Write a Review"
        titleLabel.font = .boldSystemFont(ofSize: 22)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        let ngoLabel = UILabel()
        ngoLabel.text = "for \(ngoName)"
        ngoLabel.font = .systemFont(ofSize: 14)
        ngoLabel.textAlignment = .center
        ngoLabel.textColor = .gray
        ngoLabel.translatesAutoresizingMaskIntoConstraints = false
        ngoLabel.tag = 200
        containerView.addSubview(ngoLabel)

        nameTextField.placeholder = "Your Name"
        nameTextField.borderStyle = .none
        nameTextField.backgroundColor = UIColor(white: 0.95, alpha: 1)
        nameTextField.layer.cornerRadius = 10
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        nameTextField.leftViewMode = .always
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameTextField)

        ratingLabel.text = "Your Rating"
        ratingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratingLabel)

        ratingStackView.axis = .horizontal
        ratingStackView.spacing = 8
        ratingStackView.distribution = .fillEqually
        ratingStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(ratingStackView)

        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.tag = i
            starButton.titleLabel?.font = .systemFont(ofSize: 30)
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starButtons.append(starButton)
            ratingStackView.addArrangedSubview(starButton)
        }
        updateStarDisplay()

        commentTextView.font = .systemFont(ofSize: 16)
        commentTextView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        commentTextView.layer.cornerRadius = 10
        commentTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(commentTextView)

        let placeholderLabel = UILabel()
        placeholderLabel.text = "Write your review here..."
        placeholderLabel.font = .systemFont(ofSize: 16)
        placeholderLabel.textColor = .lightGray
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.tag = 100
        commentTextView.addSubview(placeholderLabel)

        commentTextView.delegate = self

        submitButton.setTitle("Submit Review", for: .normal)
        submitButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        submitButton.backgroundColor = UIColor(red: 0.173, green: 0.193, blue: 0.148, alpha: 1.0)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 12
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(submitButton)

        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(cancelButton)
    }

    private func setupConstraints() {
        guard let ngoLabel = containerView.viewWithTag(200),
              let placeholderLabel = commentTextView.viewWithTag(100) else { return }

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            ngoLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            ngoLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            ngoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            nameTextField.topAnchor.constraint(equalTo: ngoLabel.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            nameTextField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            nameTextField.heightAnchor.constraint(equalToConstant: 50),

            ratingLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            ratingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),

            ratingStackView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 10),
            ratingStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            ratingStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            ratingStackView.heightAnchor.constraint(equalToConstant: 44),

            commentTextView.topAnchor.constraint(equalTo: ratingStackView.bottomAnchor, constant: 20),
            commentTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 120),

            placeholderLabel.topAnchor.constraint(equalTo: commentTextView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: commentTextView.leadingAnchor, constant: 15),

            submitButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50),

            cancelButton.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 10),
            cancelButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
        ])
    }

    @objc private func starTapped(_ sender: UIButton) {
        selectedRating = sender.tag
        updateStarDisplay()
    }

    private func updateStarDisplay() {
        for (index, button) in starButtons.enumerated() {
            button.setTitle(index < selectedRating ? "⭐️" : "☆", for: .normal)
        }
    }

    @objc private func submitTapped() {
        guard !ngoId.isEmpty else {
            showAlert(message: "NGO not found.")
            return
        }

        guard let name = nameTextField.text, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(message: "Please enter your name.")
            return
        }

        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !comment.isEmpty else {
            showAlert(message: "Please write your review.")
            return
        }

        let data: [String: Any] = [
            "name": name,
            "rating": selectedRating,
            "comment": comment,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("ngos_reviews")
            .document(ngoId)
            .collection("reviews")
            .addDocument(data: data) { [weak self] error in

                if let error = error {
                    self?.showAlert(message: error.localizedDescription)
                    return
                }

                self?.delegate?.didAddReview(name: name, rating: self?.selectedRating ?? 5, comment: comment)
                self?.dismiss(animated: true)
            }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddReviewViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let placeholder = textView.viewWithTag(100) as? UILabel {
            placeholder.isHidden = !textView.text.isEmpty
        }
    }
}
