//
//  NGOReviewDetailViewController.swift
//  AppPlateFul-New
//
//  202301686 - Hasan
//

import UIKit
import FirebaseFirestore

/// Admin review screen for a single NGO submission.
/// Shows NGO details and allows the admin to approve or reject the request.
/// Decisions are persisted in Firestore and the previous screen is notified via a callback.
final class NGOReviewDetailViewController: UIViewController {

    // MARK: - Outlets (Storyboard)
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var areaValueLabel: UILabel!
    @IBOutlet private weak var hoursValueLabel: UILabel!
    @IBOutlet private weak var pickupTimeValueLabel: UILabel!
    @IBOutlet private weak var donationsValueLabel: UILabel!
    @IBOutlet private weak var reliabilityValueLabel: UILabel!
    @IBOutlet private weak var reviewsValueLabel: UILabel!
    @IBOutlet private weak var approveButton: UIButton!
    @IBOutlet private weak var rejectButton: UIButton!

    // MARK: - Input
    /// The NGO item selected from the review list screen.
    var ngo: NGOReviewItem?

    /// Called after a successful approve/reject so the list can refresh/remove the item.
    var onDecision: ((String) -> Void)?

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - UI Safety
    /// Prevents duplicate writes when the user taps buttons quickly.
    private var isSaving = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NGO Detail"
        setupUI()
        fillData()
    }

    // MARK: - UI Setup
    private func setupUI() {
        logoImageView.layer.cornerRadius = 35
        logoImageView.clipsToBounds = true

        approveButton.layer.cornerRadius = 10
        rejectButton.layer.cornerRadius = 10
    }

    // MARK: - Data Binding
    /// Populates labels from the selected NGO model and loads the logo asynchronously.
    private func fillData() {
        guard let ngo = ngo else { return }

        nameLabel.text = ngo.name
        statusLabel.text = ngo.status
        areaValueLabel.text = ngo.area
        hoursValueLabel.text = ngo.openingHours
        pickupTimeValueLabel.text = ngo.avgPickupTime
        donationsValueLabel.text = ngo.collectedDonations
        reliabilityValueLabel.text = ngo.pickupReliability
        reviewsValueLabel.text = ngo.communityReviews

        // Fallback placeholder while the logo loads.
        logoImageView.image = UIImage(systemName: "photo")

        // Load logo using shared ImageLoader (cached + async).
        ImageLoader.shared.load(ngo.logoURL) { [weak self] img in
            DispatchQueue.main.async {
                self?.logoImageView.image = img ?? UIImage(systemName: "photo")
            }
        }
    }

    // MARK: - Actions
    @IBAction private func approveButtonTapped(_ sender: UIButton) {
        handleDecision(approved: true)
    }

    @IBAction private func rejectButtonTapped(_ sender: UIButton) {
        handleDecision(approved: false)
    }

    // MARK: - UI State Helpers
    private func setButtonsEnabled(_ enabled: Bool) {
        approveButton.isEnabled = enabled
        rejectButton.isEnabled = enabled
        approveButton.alpha = enabled ? 1.0 : 0.6
        rejectButton.alpha = enabled ? 1.0 : 0.6
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Firestore Logic
    /// Saves the admin decision to Firestore.
    /// - Approve: updates the existing pending review document.
    /// - Reject: moves the document to a rejected collection and removes it from pending.
    private func handleDecision(approved: Bool) {
        guard let ngo = ngo else { return }
        if isSaving { return }

        isSaving = true
        setButtonsEnabled(false)

        let reviewRef = db.collection("ngo_reviews").document(ngo.id)

        // APPROVE: update existing review document only.
        if approved {
            reviewRef.updateData([
                "approved": true,
                "status": "Approved"
            ]) { [weak self] err in
                guard let self = self else { return }

                self.isSaving = false
                self.setButtonsEnabled(true)

                if err != nil {
                    self.showError("Could not approve. Please try again.")
                    return
                }

                // Notify previous screen and navigate back.
                self.onDecision?(ngo.id)
                self.navigationController?.popViewController(animated: true)
            }
            return
        }

        // REJECT: copy to rejected collection, then delete from pending.
        let rejectedRef = db.collection("ngo_rejected").document(ngo.id)

        // Batch keeps the operation consistent (both actions succeed or fail together).
        let batch = db.batch()
        batch.setData(
            ngo.toFirestoreData(approved: false, status: "Rejected"),
            forDocument: rejectedRef
        )
        batch.deleteDocument(reviewRef)

        batch.commit { [weak self] err in
            guard let self = self else { return }

            self.isSaving = false
            self.setButtonsEnabled(true)

            if err != nil {
                self.showError("Could not reject. Please try again.")
                return
            }

            self.onDecision?(ngo.id)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
