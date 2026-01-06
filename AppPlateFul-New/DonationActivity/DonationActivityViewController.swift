//
//  DonationActivityViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Displays donation activity list with filtering and reporting support
class DonationActivityViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    
    // MARK: - Properties
    private var donations: [DonationActivityDonation] = []
    private var currentFilter: FilterOption = .all
    private var filterButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        setupFilterButton()
        setupNotifications()
        loadDonations()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    // Configures table view and base UI
    private func setupUI() {
        view.backgroundColor = DonationTheme.backgroundColor
        tableView.backgroundColor = DonationTheme.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "DonationCell"
        )
    }
    
    // Configures navigation bar appearance
    private func setupNavigationBar() {
        title = "Donation Activity"
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    // Adds filter button to navigation bar
    private func setupFilterButton() {
        filterButton = UIButton(type: .system)
        filterButton.setTitle("Filter ", for: .normal)
        filterButton.setImage(
            UIImage(systemName: "chevron.down"),
            for: .normal
        )
        filterButton.semanticContentAttribute = .forceRightToLeft
        filterButton.titleLabel?.font = UIFont.systemFont(
            ofSize: 14,
            weight: .medium
        )
        filterButton.tintColor = DonationTheme.textPrimary
        filterButton.backgroundColor = .white
        filterButton.layer.cornerRadius = 16
        filterButton.layer.borderWidth = 1
        filterButton.layer.borderColor = UIColor.systemGray4.cgColor
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 16,
            bottom: 8,
            trailing: 12
        )
        filterButton.configuration = config
        
        filterButton.addTarget(
            self,
            action: #selector(filterTapped),
            for: .touchUpInside
        )
        
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(customView: filterButton)
    }
    
    // Registers notification listeners for data updates
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatusUpdate),
            name: .donationStatusUpdated,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDonationReported),
            name: .donationReported,
            object: nil
        )
    }
    
    // MARK: - Data
    // Loads donations based on selected filter
    private func loadDonations() {
        donations =
            DonationDataProvider.shared.filteredDonations(
                by: currentFilter
            )
        emptyStateLabel?.isHidden = !donations.isEmpty
        tableView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func filterTapped() {
        let filterVC =
            FilterPopupViewController(currentFilter: currentFilter)
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .overCurrentContext
        filterVC.modalTransitionStyle = .crossDissolve
        present(filterVC, animated: true)
    }
    
    @objc private func handleStatusUpdate(_ notification: Notification) {
        loadDonations()
    }
    
    @objc private func handleDonationReported(_ notification: Notification) {
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    // Shows confirmation popup for reporting a donation
    private func showReportConfirmation(
        for donation: DonationActivityDonation
    ) {
        let popup = ReportConfirmationPopup()
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        popup.onConfirm = { [weak self] in
            DonationDataProvider.shared.reportDonation(
                donationId: donation.id
            )
            self?.showReportedAlert()
        }
        present(popup, animated: true)
    }
    
    // Displays confirmation alert after reporting
    private func showReportedAlert() {
        let alert = StatusUpdatedPopup(
            icon: UIImage(
                systemName: "exclamationmark.triangle.fill"
            ),
            message: "Donation Reported",
            iconColor: .systemOrange
        )
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 1.5
            ) {
                alert.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension DonationActivityViewController:
    UITableViewDelegate,
    UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        donations.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let donation = donations[indexPath.row]
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DonationCell",
            for: indexPath
        )
        
        var content = cell.defaultContentConfiguration()
        content.text = donation.ngoName
        content.secondaryText =
            "\(donation.status.rawValue) • \(donation.formattedCreatedDate)"
        content.secondaryTextProperties.color =
            donation.status.color
        content.image =
            donation.ngoLogo ??
            UIImage(systemName: "building.2.fill")
        content.imageProperties.maximumSize =
            CGSize(width: 60, height: 60)
        content.imageProperties.cornerRadius = 10
        content.imageProperties.tintColor =
            DonationTheme.primaryBrown
        
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = DonationTheme.cardBackground
        
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let donation = donations[indexPath.row]
        guard let detailVC =
            storyboard?.instantiateViewController(
                withIdentifier: "DonationDetailViewController"
            ) as? DonationDetailViewController else {
            return
        }
        
        detailVC.donation = donation
        navigationController?.pushViewController(
            detailVC,
            animated: true
        )
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        100
    }
}

// MARK: - FilterPopupDelegate
extension DonationActivityViewController: FilterPopupDelegate {
    func didSelectFilter(_ filter: FilterOption) {
        currentFilter = filter
        filterButton.setTitle("\(filter.rawValue) ", for: .normal)
        loadDonations()
    }
}
