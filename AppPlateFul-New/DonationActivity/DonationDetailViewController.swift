//
//  DonationDetailViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

class DonationDetailViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var detailLogoImageView: UIImageView!
    @IBOutlet weak var detailNgoNameLabel: UILabel!
    @IBOutlet weak var detailDateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var itemsStackView: UIStackView!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var changeStatusButton: UIButton!
    
    // MARK: - Properties
    var donation: DonationActivityDonation?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureContent()
        setupNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = DonationTheme.backgroundColor
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatusUpdate),
            name: .donationStatusUpdated,
            object: nil
        )
    }
    
    // MARK: - Content
    private func configureContent() {
        guard let donation else { return }
        
        // Logo
        detailLogoImageView.image = donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        detailLogoImageView.tintColor = DonationTheme.primaryBrown
        
        // NGO Info
        detailNgoNameLabel.text = donation.ngoName
        detailDateLabel.text = donation.formattedCreatedDate
        
        // Address
        addressLabel.text = donation.address.formattedAddress
        phoneLabel.text = "📞 \(donation.address.mobileNumber)"
        
        // Items
        setupItemsStack()
        
        // Status
        updateStatusDisplay()
    }
    
    private func setupItemsStack() {
        guard let donation else { return }
        
        // Clear existing items
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add item labels
        for item in donation.items {
            let itemLabel = UILabel()
            itemLabel.font = UIFont.systemFont(ofSize: 14)
            itemLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
            itemLabel.text = "• \(item.name) (x\(item.quantity))"
            itemsStackView.addArrangedSubview(itemLabel)
        }
    }
    
    private func updateStatusDisplay() {
        guard let donation else { return }
        currentStatusLabel.text = donation.status.rawValue
        currentStatusLabel.textColor = donation.status.color
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeStatusTapped(_ sender: Any) {
        guard let donation else { return }
        
        let changeStatusVC = ChangeStatusViewController(currentStatus: donation.status)
        changeStatusVC.delegate = self
        changeStatusVC.modalPresentationStyle = .overCurrentContext
        changeStatusVC.modalTransitionStyle = .crossDissolve
        present(changeStatusVC, animated: true)
    }
    
    @IBAction func reportTapped(_ sender: Any) {
        showReportConfirmation()
    }
    
    private func showReportConfirmation() {
        guard let donation else { return }
        
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
    
    // MARK: - Notification Handling
    @objc private func handleStatusUpdate(_ notification: Notification) {
        guard let updatedDonation = notification.object as? DonationActivityDonation,
              let donation,
              updatedDonation.id == donation.id else {
            return
        }
        
        self.donation = updatedDonation
        updateStatusDisplay()
    }
}

// MARK: - ChangeStatusDelegate
extension DonationDetailViewController: ChangeStatusDelegate {
    
    func didChangeStatus(to newStatus: DonationActivityStatus) {
        guard let donation else { return }
        
        DonationDataProvider.shared.updateDonationStatus(
            donationId: donation.id,
            newStatus: newStatus
        )
        
        let successPopup = StatusUpdatedPopup(
            icon: UIImage(systemName: "checkmark.circle.fill"),
            message: "Status Updated",
            iconColor: DonationTheme.statusCompleted
        )
        
        successPopup.modalPresentationStyle = .overCurrentContext
        successPopup.modalTransitionStyle = .crossDissolve
        present(successPopup, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                successPopup.dismiss(animated: true)
            }
        }
    }
}
