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
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Style the button
        backButton.backgroundColor = .white
        backButton.setTitle("‹", for: .normal)
        backButton.setTitleColor(UIColor(red: 0.256, green: 0.573, blue: 0.166, alpha: 1.0), for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        backButton.layer.cornerRadius = 22
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 4
        
        // Add action
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // Add to view
        view.addSubview(backButton)
        
        // Constraints
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Bring to front
        view.bringSubviewToFront(backButton)
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
        
        if let emptyStateView = emptyStateLabel?.superview {
            emptyStateView.isHidden = !donations.isEmpty
        }
        
        tableView.reloadData()
    }
    
    private func updateStats() {
        let allDonations = DonationDataProvider.shared.donations
        
        totalCountLabel.text = "\(allDonations.count)"
        
        let completedCount = allDonations.filter {
            $0.status == .completed || $0.status == .pickedUp
        }.count
        completedCountLabel.text = "\(completedCount)"
        
        let pendingCount = allDonations.filter {
            $0.status == .pending || $0.status == .ongoing
        }.count
        pendingCountLabel.text = "\(pendingCount)"
    }
    
    // MARK: - Actions
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

        // 5) Final fallback: reset root to AdminDashboard (key window correctly)
        let sb = UIStoryboard(name: "AdminDashboard", bundle: nil)

        // Prefer a known storyboard ID (best), otherwise initial VC
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

        UIView.transition(with: window,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: nil)
    }

    
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
