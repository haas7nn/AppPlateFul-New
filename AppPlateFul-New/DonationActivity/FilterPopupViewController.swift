//
//  FilterPopupViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Sends the selected filter back to the presenting screen.
/// The popup stays UI-only; it does not filter data by itself.
protocol FilterPopupDelegate: AnyObject {
    func didSelectFilter(_ filter: FilterOption)
}

/// A small modal popup that lets the user choose a filter option.
/// It uses a dimmed background and returns the selection via a delegate.
final class FilterPopupViewController: UIViewController {

    // MARK: - Communication
    weak var delegate: FilterPopupDelegate?

    // MARK: - State
    private var currentFilter: FilterOption

    // MARK: - UI
    /// Dim background to focus the user and enable tap-to-dismiss.
    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Center popup container.
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

    /// Holds the list of filter buttons in a neat vertical layout.
    private let optionsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Init
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

    // MARK: - Layout
    private func setupUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(optionsStackView)

        // Tapping outside the popup closes it (common modal UX pattern).
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
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

    // MARK: - Options
    private func createFilterOptions() {
        for (index, option) in FilterOption.allCases.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(option.rawValue, for: .normal)
            button.setTitleColor(DonationTheme.textPrimary, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)

            // Left aligned to look like a list item.
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)

            // Highlight the currently selected filter.
            button.backgroundColor = (option == currentFilter) ? DonationTheme.cardBackground : .clear
            button.layer.cornerRadius = 10

            // Use index mapping so we can find the selected option quickly.
            button.tag = index
            button.addTarget(self, action: #selector(optionSelected(_:)), for: .touchUpInside)

            // Add a checkmark for the active selection.
            if option == currentFilter {
                let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
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
