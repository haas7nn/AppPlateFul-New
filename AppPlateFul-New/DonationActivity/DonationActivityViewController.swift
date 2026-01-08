//
//  DonationActivityViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

class DonationActivityViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel?
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var completedCountLabel: UILabel!
    @IBOutlet weak var pendingCountLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    
    // MARK: - Properties
    private var donations: [DonationActivityDonation] = []
    private var currentFilter: FilterOption = .all
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNotifications()
        loadDonations()
        updateStats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar since we have custom header
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show navigation bar for other screens
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = DonationTheme.backgroundColor
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.separatorStyle = .none
    }
    
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
    private func loadDonations() {
        donations = DonationDataProvider.shared.filteredDonations(by: currentFilter)
        
        // Update empty state
        if let emptyStateView = emptyStateLabel?.superview {
            emptyStateView.isHidden = !donations.isEmpty
        }
        
        tableView.reloadData()
    }
    
    private func updateStats() {
        let allDonations = DonationDataProvider.shared.donations
        
        // Total count
        totalCountLabel.text = "\(allDonations.count)"
        
        // Completed count (completed + picked up)
        let completedCount = allDonations.filter {
            $0.status == .completed || $0.status == .pickedUp
        }.count
        completedCountLabel.text = "\(completedCount)"
        
        // Pending count (pending + ongoing)
        let pendingCount = allDonations.filter {
            $0.status == .pending || $0.status == .ongoing
        }.count
        pendingCountLabel.text = "\(pendingCount)"
    }
    
    // MARK: - Actions
    @IBAction func filterButtonTapped(_ sender: Any) {
        showFilterPopup()
    }
    
    private func showFilterPopup() {
        let filterVC = FilterPopupViewController(currentFilter: currentFilter)
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .overCurrentContext
        filterVC.modalTransitionStyle = .crossDissolve
        present(filterVC, animated: true)
    }
    
    @objc private func handleStatusUpdate(_ notification: Notification) {
        loadDonations()
        updateStats()
    }
    
    @objc private func handleDonationReported(_ notification: Notification) {
        tableView.reloadData()
    }
    
    // MARK: - Navigation
    private func showReportConfirmation(for donation: DonationActivityDonation) {
        let popup = ReportConfirmationPopup()
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve
        popup.onConfirm = { [weak self] in
            DonationDataProvider.shared.reportDonation(donationId: donation.id)
            self?.showReportedAlert()
        }
        present(popup, animated: true)
    }
    
    private func showReportedAlert() {
        let alert = StatusUpdatedPopup(
            icon: UIImage(systemName: "exclamationmark.triangle.fill"),
            message: "Donation Reported",
            iconColor: .systemOrange
        )
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension DonationActivityViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        donations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DonationActivityCell",
            for: indexPath
        ) as? DonationActivityCell else {
            return UITableViewCell()
        }
        
        let donation = donations[indexPath.row]
        cell.configure(with: donation)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let donation = donations[indexPath.row]
        guard let detailVC = storyboard?.instantiateViewController(
            withIdentifier: "DonationDetailViewController"
        ) as? DonationDetailViewController else {
            return
        }
        
        detailVC.donation = donation
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        116 // Updated for new compact cell design
    }
}

// MARK: - FilterPopupDelegate
extension DonationActivityViewController: FilterPopupDelegate {
    func didSelectFilter(_ filter: FilterOption) {
        currentFilter = filter
        loadDonations()
    }
}

// MARK: - DonationActivityCellDelegate
extension DonationActivityViewController: DonationActivityCellDelegate {
    func didTapReport(for donation: DonationActivityDonation) {
        showReportConfirmation(for: donation)
    }
}
