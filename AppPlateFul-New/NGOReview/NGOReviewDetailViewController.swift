//
//  NGOReviewDetailViewController.swift
//  AppPlateFul-New
//
//  202301686 - Hasan
//

import UIKit
import FirebaseFirestore

// Displays detailed NGO information and allows admin approval or rejection
class NGOReviewDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var areaValueLabel: UILabel!
    @IBOutlet weak var hoursValueLabel: UILabel!
    @IBOutlet weak var pickupTimeValueLabel: UILabel!
    @IBOutlet weak var donationsValueLabel: UILabel!
    @IBOutlet weak var reliabilityValueLabel: UILabel!
    @IBOutlet weak var reviewsValueLabel: UILabel!
    @IBOutlet weak var approveButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!

    // Selected NGO item
    var ngo: NGOReviewItem?

    // Callback triggered after approval or rejection
    var onDecision: ((String) -> Void)?

    // Firestore reference
    private let db = Firestore.firestore()

    // Prevents multiple save actions
    private var isSaving = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NGO Detail"
        setupUI()
        fillData()
    }

    // MARK: - Setup
    private func setupUI() {
        logoImageView.layer.cornerRadius = 35
        logoImageView.clipsToBounds = true
        approveButton.layer.cornerRadius = 10
        rejectButton.layer.cornerRadius = 10
    }

    // MARK: - Fill UI
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

        logoImageView.image = UIImage(systemName: "photo")

        ImageLoader.shared.load(ngo.logoURL) { [weak self] img in
            DispatchQueue.main.async {
                self?.logoImageView.image = img ?? UIImage(systemName: "photo")
            }
        }
    }

    // MARK: - IBActions
    @IBAction func approveButtonTapped(_ sender: UIButton) {
        handleDecision(approved: true)
    }

    @IBAction func rejectButtonTapped(_ sender: UIButton) {
        handleDecision(approved: false)
    }

    // MARK: - UI State
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
    private func handleDecision(approved: Bool) {
        guard let ngo = ngo else { return }
        if isSaving { return }

        isSaving = true
        setButtonsEnabled(false)

        let reviewRef = db.collection("ngo_reviews").document(ngo.id)

        // APPROVE: update existing document only
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

                self.onDecision?(ngo.id)
                self.navigationController?.popViewController(animated: true)
            }
            return
        }

        // REJECT: copy to rejected collection, then delete from pending
        let rejectedRef = db.collection("ngo_rejected").document(ngo.id)

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
