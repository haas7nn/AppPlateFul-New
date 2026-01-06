//
//  FilterPopupViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Delegate protocol for communicating selected filter option
protocol FilterPopupDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterOption)
}

// Popup view controller for selecting donation filters
class FilterPopupViewController: UIViewController {
    
    // MARK: - Delegate
    weak var delegate: FilterPopupDelegate?
    
    // MARK: - State
    private var currentFilter: FilterOption
    
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
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Filter Donations"
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initializers
    init(currentFilter: FilterOption) {
        self.currentFilter = currentFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.currentFilter = .all
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        createFilterOptions()
    }
    
    // MARK: - UI Setup
    // Builds and lays out the popup interface
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(optionsStackView)
        
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissPopup)
        )
        backgroundView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            optionsStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            optionsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            optionsStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Filter Options
    // Creates selectable filter buttons
    private func createFilterOptions() {
        for (index, option) in FilterOption.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option.rawValue, for: .normal)
            button.setTitleColor(DonationTheme.textPrimary, for: .normal)
            button.titleLabel?.font =
                UIFont.systemFont(ofSize: 16, weight: .medium)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets =
                UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
            button.backgroundColor =
                option == currentFilter ? DonationTheme.cardBackground : .clear
            button.layer.cornerRadius = 10
            button.tag = index
            button.addTarget(
                self,
                action: #selector(optionSelected(_:)),
                for: .touchUpInside
            )
            
            // Indicates currently selected filter
            if option == currentFilter {
                let checkmark =
                    UIImageView(image: UIImage(systemName: "checkmark"))
                checkmark.tintColor = DonationTheme.primaryBrown
                checkmark.translatesAutoresizingMaskIntoConstraints = false
                button.addSubview(checkmark)
                NSLayoutConstraint.activate([
                    checkmark.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                    checkmark.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16)
                ])
            }
            
            optionsStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Actions
    @objc private func optionSelected(_ sender: UIButton) {
        let selectedFilter = FilterOption.allCases[sender.tag]
        delegate?.didSelectFilter(selectedFilter)
        dismiss(animated: true)
    }
    
    @objc private func dismissPopup() {
        dismiss(animated: true)
    }
}
