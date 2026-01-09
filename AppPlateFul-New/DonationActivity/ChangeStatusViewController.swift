//
//  ChangeStatusViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Delegate protocol for notifying status changes
protocol ChangeStatusDelegate: AnyObject {
    func didChangeStatus(to newStatus: DonationActivityStatus)
}

// Bottom sheet view controller for changing donation activity status
class ChangeStatusViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: ChangeStatusDelegate?
    
    // MARK: - State
    private var currentStatus: DonationActivityStatus
    private var selectedStatus: DonationActivityStatus?
    
    // Available status options
    private let statusOptions: [DonationActivityStatus] = [
        .pending,
        .ongoing,
        .completed,
        .pickedUp,
        .cancelled
    ]
    
    // Stores radio button references
    private var optionButtons: [UIButton] = []
    
    // MARK: - UI Elements
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
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
    
    // MARK: - Initializers
    init(currentStatus: DonationActivityStatus) {
        self.currentStatus = currentStatus
        super.init(nibName: nil, bundle: nil)
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
    
    // MARK: - UI Setup
    // Builds and lays out the popup interface
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(handleBar)
        containerView.addSubview(titleLabel)
        containerView.addSubview(optionsStackView)
        containerView.addSubview(updateButton)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissPopup)
        )
        backgroundView.addGestureRecognizer(tapGesture)
        
        updateButton.addTarget(
            self,
            action: #selector(updateTapped),
            for: .touchUpInside
        )
        
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
    
    // Creates selectable status option rows
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
            radioButton.addTarget(
                self,
                action: #selector(optionSelected(_:)),
                for: .touchUpInside
            )
            radioButton.translatesAutoresizingMaskIntoConstraints = false
            optionButtons.append(radioButton)
            
            let statusLabel = UILabel()
            statusLabel.text = status.rawValue
            statusLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            statusLabel.textColor = status.color
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
            
            container.addSubview(radioButton)
            container.addSubview(statusLabel)
            
            let tapGesture = UITapGestureRecognizer(
                target: self,
                action: #selector(containerTapped(_:))
            )
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
    
    // MARK: - Selection Handling
    @objc private func optionSelected(_ sender: UIButton) {
        selectOption(at: sender.tag)
    }
    
    @objc private func containerTapped(_ gesture: UITapGestureRecognizer) {
        if let tag = gesture.view?.tag {
            selectOption(at: tag)
        }
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
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didChangeStatus(to: selectedStatus)
        }
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
}
