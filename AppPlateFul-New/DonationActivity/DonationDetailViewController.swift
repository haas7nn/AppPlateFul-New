//
//  DonationDetailViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Displays detailed information for a selected donation and supports status updates
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup
    // Configures base UI appearance
    private func setupUI() {
        view.backgroundColor = DonationTheme.backgroundColor
        title = "Donation Details"
    }
    
    // Registers notification listener for status updates
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStatusUpdate),
            name: .donationStatusUpdated,
            object: nil
        )
    }
    
    // MARK: - Content
    // Populates the UI with donation information
    private func configureContent() {
        guard let donation else { return }
        
        detailLogoImageView.image =
            donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        detailLogoImageView.tintColor = DonationTheme.primaryBrown
        
        detailNgoNameLabel.text = donation.ngoName
        detailDateLabel.text = donation.formattedCreatedDate
        
        addressLabel.text = donation.address.formattedAddress
        phoneLabel.text = "📞 \(donation.address.mobileNumber)"
        
        // Clears any previous item labels
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Adds item labels dynamically
        for item in donation.items {
            let itemLabel = UILabel()
            itemLabel.font = UIFont.systemFont(ofSize: 13)
            itemLabel.textColor = DonationTheme.textSecondary
            itemLabel.text = "• \(item.name) (x\(item.quantity))"
            itemsStackView.addArrangedSubview(itemLabel)
        }
        
        updateStatusDisplay()
    }
    
    // Updates status label text and color
    private func updateStatusDisplay() {
        guard let donation else { return }
        currentStatusLabel.text = donation.status.rawValue
        currentStatusLabel.textColor = donation.status.color
    }
    
    // MARK: - Actions
    // Opens the change status popup
    @IBAction func changeStatusTapped(_ sender: Any) {
        guard let donation else { return }
        
        let changeStatusVC =
            ChangeStatusViewController(currentStatus: donation.status)
        changeStatusVC.delegate = self
        changeStatusVC.modalPresentationStyle = .overCurrentContext
        changeStatusVC.modalTransitionStyle = .crossDissolve
        present(changeStatusVC, animated: true)
    }
    
    // MARK: - Notification Handling
    // Receives updated donation data and refreshes the status label
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
    
    // Updates donation status using data provider and shows success feedback
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
