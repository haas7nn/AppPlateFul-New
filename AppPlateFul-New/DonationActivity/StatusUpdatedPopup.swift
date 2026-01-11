//
//  StatusUpdatedPopup.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Small feedback popup used after quick actions (e.g., "Status Updated", "Donation Reported").
/// This view controller only renders UI; the presenting screen decides when to dismiss it.
final class StatusUpdatedPopup: UIViewController {

    // MARK: - Input
    private let icon: UIImage?
    private let message: String
    private let iconColor: UIColor

    // MARK: - UI
    /// Dim background to keep focus on the popup (same style as other overlays in the app).
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Compact container sized to feel like a toast/confirmation card.
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init
    /// Initialize with the content to display.
    /// This keeps the popup reusable for multiple messages/actions.
    init(icon: UIImage?, message: String, iconColor: UIColor) {
        self.icon = icon
        self.message = message
        self.iconColor = iconColor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        // This popup is created programmatically, not from storyboard.
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - Layout
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)

        containerView.addSubview(iconImageView)
        containerView.addSubview(messageLabel)

        iconImageView.image = icon
        iconImageView.tintColor = iconColor
        messageLabel.text = message

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 200),

            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),

            messageLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -32)
        ])
    }
}
