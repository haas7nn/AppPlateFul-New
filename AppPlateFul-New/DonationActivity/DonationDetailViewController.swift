//
//  DonationDetailViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Displays full details for a single donation:
/// NGO info, address, items list, and current status.
/// Also allows the admin/user to change status (bottom sheet) or report the donation.
final class DonationDetailViewController: UIViewController {

    // MARK: - Outlets (Storyboard)
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var detailLogoImageView: UIImageView!
    @IBOutlet private weak var detailNgoNameLabel: UILabel!
    @IBOutlet private weak var detailDateLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var phoneLabel: UILabel!
    @IBOutlet private weak var itemsStackView: UIStackView!
    @IBOutlet private weak var currentStatusLabel: UILabel!
    @IBOutlet private weak var changeStatusButton: UIButton!

    // MARK: - Input
    /// The selected donation passed in from the activity list screen.
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

        // This screen uses a custom back button in the UI, so we hide the default nav bar.
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
        // If status is updated elsewhere, we refresh the status UI for the current donation.
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

        // NGO logo (fallback icon if not available).
        detailLogoImageView.image = donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        detailLogoImageView.tintColor = DonationTheme.primaryBrown

        // Basic donation info.
        detailNgoNameLabel.text = donation.ngoName
        detailDateLabel.text = donation.formattedCreatedDate

        // Address / contact.
        addressLabel.text = donation.address.formattedAddress
        phoneLabel.text = "📞 \(donation.address.mobileNumber)"

        // Items list is dynamic, so we build it programmatically inside the stack view.
        setupItemsStack()

        // Current status is shown with text + color for quick readability.
        updateStatusDisplay()
    }

    private func setupItemsStack() {
        guard let donation else { return }

        // Prevent duplicates if the view reloads or updates.
        itemsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

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
    @IBAction private func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func changeStatusTapped(_ sender: Any) {
        guard let donation else { return }

        // Bottom sheet for picking a status; the result comes back through the delegate.
        let changeStatusVC = ChangeStatusViewController(currentStatus: donation.status)
        changeStatusVC.delegate = self
        changeStatusVC.modalPresentationStyle = .overCurrentContext
        changeStatusVC.modalTransitionStyle = .crossDissolve
        present(changeStatusVC, animated: true)
    }

    @IBAction private func reportTapped(_ sender: Any) {
        showReportConfirmation()
    }

    // MARK: - Report Flow
    private func showReportConfirmation() {
        guard let donation else { return }

        let popup = ReportConfirmationPopup()
        popup.modalPresentationStyle = .overCurrentContext
        popup.modalTransitionStyle = .crossDissolve

        popup.onConfirm = { [weak self] in
            // Provider handles the state update; this screen only triggers UI feedback.
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

        // Auto dismiss so the user can keep moving without extra taps.
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                alert.dismiss(animated: true)
            }
        }
    }

    // MARK: - Notifications
    /// Receives status updates and refreshes the UI only if the update is for the same donation.
    @objc private func handleStatusUpdate(_ notification: Notification) {
        guard
            let updatedDonation = notification.object as? DonationActivityDonation,
            let donation,
            updatedDonation.id == donation.id
        else { return }

        self.donation = updatedDonation
        updateStatusDisplay()
    }
}

// MARK: - ChangeStatusDelegate
extension DonationDetailViewController: ChangeStatusDelegate {

    func didChangeStatus(to newStatus: DonationActivityStatus) {
        guard let donation else { return }

        // Central update happens in the provider; other screens can react via notification.
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

