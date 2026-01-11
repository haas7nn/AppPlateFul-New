//
//  ChangeStatusViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Notifies the presenting screen when the user confirms a new donation status.
protocol ChangeStatusDelegate: AnyObject {
    func didChangeStatus(to newStatus: DonationActivityStatus)
}

/// A lightweight bottom-sheet modal that lets the user pick a donation status and confirm the change.
/// It doesn’t update data directly; it sends the selected value back through a delegate.
final class ChangeStatusViewController: UIViewController {

    // MARK: - Communication
    weak var delegate: ChangeStatusDelegate?

    // MARK: - State
    private var currentStatus: DonationActivityStatus
    private var selectedStatus: DonationActivityStatus?

    /// The list of statuses shown as selectable rows.
    private let statusOptions: [DonationActivityStatus] = [
        .pending,
        .ongoing,
        .completed,
        .pickedUp,
        .cancelled
    ]

    /// Keeps references to the radio buttons so we can toggle selection easily.
    private var optionButtons: [UIButton] = []

    // MARK: - UI
    /// Dimmed background used to focus attention and allow tap-to-dismiss.
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The actual sheet container (rounded corners at the top).
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Small visual handle to make the sheet feel draggable (even if we don’t drag here).
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Change Status"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// Holds the status rows vertically.
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// Disabled until the user selects an option, so they can’t confirm by mistake.
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Update Status", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = DonationTheme.primaryBrown
        button.layer.cornerRadius = 20
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Init
    init(currentStatus: DonationActivityStatus) {
        self.currentStatus = currentStatus
        super.init(nibName: nil, bundle: nil)

        // Presented as an overlay so we can keep a dimmed background behind the sheet.
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        self.currentStatus = .pending
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createStatusOptions()
    }

    // MARK: - Layout
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)

        containerView.addSubview(handleBar)
        containerView.addSubview(titleLabel)
        containerView.addSubview(optionsStackView)
        containerView.addSubview(updateButton)

        // Tap outside the sheet to dismiss.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        backgroundView.addGestureRecognizer(tapGesture)

        updateButton.addTarget(self, action: #selector(updateTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            handleBar.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            handleBar.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            handleBar.widthAnchor.constraint(equalToConstant: 40),
            handleBar.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: handleBar.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            optionsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

            updateButton.topAnchor.constraint(equalTo: optionsStackView.bottomAnchor, constant: 32),
            updateButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 32),
            updateButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -32),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            updateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - Options
    private func createStatusOptions() {
        for (index, status) in statusOptions.enumerated() {
            let container = UIView()
            container.backgroundColor = DonationTheme.cardBackground
            container.layer.cornerRadius = 12
            container.translatesAutoresizingMaskIntoConstraints = false
            container.tag = index

            let radioButton = UIButton(type: .custom)
            radioButton.tag = index
            radioButton.setImage(UIImage(systemName: "circle"), for: .normal)
            radioButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
            radioButton.tintColor = DonationTheme.primaryBrown
            radioButton.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)
            radioButton.translatesAutoresizingMaskIntoConstraints = false
            optionButtons.append(radioButton)

            let statusLabel = UILabel()
            statusLabel.text = status.rawValue
            statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            statusLabel.textColor = status.color
            statusLabel.translatesAutoresizingMaskIntoConstraints = false

            container.addSubview(radioButton)
            container.addSubview(statusLabel)

            // Make the whole row tappable (not just the radio icon).
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:)))
            container.addGestureRecognizer(tapGesture)

            NSLayoutConstraint.activate([
                container.heightAnchor.constraint(equalToConstant: 56),

                radioButton.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
                radioButton.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                radioButton.widthAnchor.constraint(equalToConstant: 24),
                radioButton.heightAnchor.constraint(equalToConstant: 24),

                statusLabel.leadingAnchor.constraint(equalTo: radioButton.trailingAnchor, constant: 12),
                statusLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])

            optionsStackView.addArrangedSubview(container)
        }
    }

    // MARK: - Selection
    @objc private func optionSelected(_ sender: UIButton) {
        selectOption(at: sender.tag)
    }

    @objc private func containerTapped(_ gesture: UITapGestureRecognizer) {
        guard let tag = gesture.view?.tag else { return }
        selectOption(at: tag)
    }

    private func selectOption(at index: Int) {
        optionButtons.forEach { $0.isSelected = false }
        optionButtons[index].isSelected = true

        selectedStatus = statusOptions[index]
        updateButton.isEnabled = true
        updateButton.alpha = 1.0
    }

    // MARK: - Actions
    @objc private func updateTapped() {
        guard let selectedStatus else { return }

        // Dismiss first for smoother UX, then notify the previous screen.
        dismiss(animated: true) { [weak self] in
            // Avoid retaining the sheet during the dismissal animation.
            self?.delegate?.didChangeStatus(to: selectedStatus)
        }
    }

    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
}
