//
//  DonationActivityViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Shows a list of donation activity entries with basic stats and filtering.
/// This controller is UI-focused: it reads data from `DonationDataProvider`,
/// reacts to updates via notifications, and navigates to detail/report flows.
final class DonationActivityViewController: UIViewController {

    // MARK: - Outlets (Storyboard)
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateLabel: UILabel?
    @IBOutlet private weak var totalCountLabel: UILabel!
    @IBOutlet private weak var completedCountLabel: UILabel!
    @IBOutlet private weak var pendingCountLabel: UILabel!
    @IBOutlet private weak var filterButton: UIButton!

    // MARK: - Data
    private var donations: [DonationActivityDonation] = []
    private var currentFilter: FilterOption = .all

    // MARK: - UI State
    private var backButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupBackButton()
        setupNotifications()

        loadDonations()
        updateStats()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // This screen uses a custom back button, so we hide the default nav bar.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    deinit {
        // Good hygiene: remove observers to avoid unexpected callbacks later.
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = DonationTheme.backgroundColor

        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self

        // Adds breathing room at the bottom so the last cell doesn't feel cramped.
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.separatorStyle = .none
    }

    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        // Simple “floating” button style to match the card UI.
        backButton.backgroundColor = .white
        backButton.setTitle("‹", for: .normal)
        backButton.setTitleColor(
            UIColor(red: 0.256, green: 0.573, blue: 0.166, alpha: 1.0),
            for: .normal
        )
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        backButton.layer.cornerRadius = 22
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4

        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        // Ensure it stays above the table view.
        view.bringSubviewToFront(backButton)
    }

    private func setupNotifications() {
        // Refresh the list/stats when another screen changes a donation status.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatusUpdate),
            name: .donationStatusUpdated,
            object: nil
        )

        // Update UI after a donation gets reported (e.g., show “reported” badge/state in cells).
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDonationReported),
            name: .donationReported,
            object: nil
        )
    }

    // MARK: - Data + UI Refresh
    private func loadDonations() {
        donations = DonationDataProvider.shared.filteredDonations(by: currentFilter)

        // Show/hide empty state container depending on whether there is data.
        if let emptyStateView = emptyStateLabel?.superview {
            emptyStateView.isHidden = !donations.isEmpty
        }

        tableView.reloadData()
    }

    private func updateStats() {
        let allDonations = DonationDataProvider.shared.donations

        totalCountLabel.text = "\(allDonations.count)"

        // “Completed” includes both completed + picked up (both represent finished outcomes).
        let completedCount = allDonations.filter {
            $0.status == .completed || $0.status == .pickedUp
        }.count
        completedCountLabel.text = "\(completedCount)"

        // “Pending” includes pending + ongoing (both are active/in-progress states).
        let pendingCount = allDonations.filter {
            $0.status == .pending || $0.status == .ongoing
        }.count
        pendingCountLabel.text = "\(pendingCount)"
    }

    // MARK: - Actions
    /// Handles "back" in a safe way across different presentation styles:
    /// navigation stack, modal presentation, tab root, and a final fallback root reset.
    @objc private func backButtonTapped() {

        // 1) If we are in a nav stack and not the root -> pop
        if let nav = navigationController, nav.viewControllers.first != self {
            nav.popViewController(animated: true)
            return
        }

        // 2) If presented modally -> dismiss
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }

        // 3) If we're root of a nav stack -> go to root (still "back-ish")
        if let nav = navigationController {
            nav.popToRootViewController(animated: true)
            return
        }

        // 4) If inside a tab bar -> jump to first tab
        if let tab = tabBarController {
            tab.selectedIndex = 0
            return
        }

        // 5) Final fallback: reset root to AdminDashboard using the active key window
        let sb = UIStoryboard(name: "AdminDashboard", bundle: nil)

        let adminRoot: UIViewController
        if let nav = sb.instantiateViewController(withIdentifier: "AdminDashboardNav") as? UINavigationController {
            adminRoot = nav
        } else if let initial = sb.instantiateInitialViewController() {
            adminRoot = initial
        } else {
            assertionFailure("AdminDashboard storyboard misconfigured")
            return
        }

        guard
            let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
        else { return }

        adminRoot.modalPresentationStyle = .fullScreen
        window.rootViewController = adminRoot
        window.makeKeyAndVisible()

        UIView.transition(
            with: window,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }

    @IBAction private func filterButtonTapped(_ sender: Any) {
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
        // Status changes affect both the visible list and the summary counts.
        loadDonations()
        updateStats()
    }

    @objc private func handleDonationReported(_ notification: Notification) {
        // Keep this lightweight; the provider already has the updated report state.
        tableView.reloadData()
    }

    // MARK: - Report Flow
    private func showReportConfirmation(for donation: DonationActivityDonation) {
        let popup = ReportConfirmationPopup()
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve

        popup.onConfirm = { [weak self] in
            // Provider handles the state change; controller only triggers UI feedback.
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

        // Auto-dismiss so the user doesn’t have to tap anything.
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource + UITableViewDelegate
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

        // Detail screen shows full info + status updates.
        guard let detailVC = storyboard?.instantiateViewController(
            withIdentifier: "DonationDetailViewController"
        ) as? DonationDetailViewController else {
            return
        }

        detailVC.donation = donation
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        116
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
