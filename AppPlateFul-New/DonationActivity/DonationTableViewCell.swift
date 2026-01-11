//
//  DonationTableViewCell.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Lightweight table view cell used to display a compact donation summary.
/// This cell focuses only on presentation and does not contain any business logic.
final class DonationTableViewCell: UITableViewCell {

    // MARK: - Outlets (Storyboard)
    @IBOutlet private weak var logoImageView: UIImageView?
    @IBOutlet private weak var ngoNameLabel: UILabel?
    @IBOutlet private weak var statusLabel: UILabel?
    @IBOutlet private weak var dateLabel: UILabel?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Rounded logo to match card-style UI across the app.
        logoImageView?.layer.cornerRadius = 10
        logoImageView?.clipsToBounds = true
    }

    // MARK: - Configuration
    /// Populates the cell using a donation model provided by the table view controller.
    func configure(with donation: DonationActivityDonation) {
        // NGO logo with a fallback icon if no image exists.
        logoImageView?.image = donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        logoImageView?.tintColor = DonationTheme.primaryBrown

        ngoNameLabel?.text = donation.ngoName

        // Status uses both text and color for quick visual recognition.
        statusLabel?.text = donation.status.rawValue
        statusLabel?.textColor = donation.status.color

        // Full date format keeps this cell informative without extra UI.
        dateLabel?.text = donation.formattedCreatedDate
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        // Clear old content to prevent reused cells showing incorrect data.
        logoImageView?.image = nil
        ngoNameLabel?.text = nil
        statusLabel?.text = nil
        dateLabel?.text = nil
    }
}
