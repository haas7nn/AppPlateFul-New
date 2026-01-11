//
//  DonationActivityCell.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Cell-level callbacks so the table screen can react to actions inside the cell
/// without the cell needing to know anything about navigation or reporting logic.
protocol DonationActivityCellDelegate: AnyObject {
    func didTapReport(for donation: DonationActivityDonation)
}

/// Displays one donation activity item in the table (NGO info, items, status, and date).
/// The cell is only responsible for UI; business logic stays in the view controller.
final class DonationActivityCell: UITableViewCell {

    // MARK: - Outlets (Storyboard)
    @IBOutlet private weak var cardContainer: UIView!
    @IBOutlet private weak var logoContainer: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var ngoNameLabel: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var itemsLabel: UILabel!

    /// Optional outlets kept to avoid breaking storyboard connections in older scenes.
    /// If these are not connected in the current storyboard, the cell still works normally.
    @IBOutlet private weak var statusDetailLabel: UILabel?
    @IBOutlet private weak var pickupDateLabel: UILabel?
    @IBOutlet private weak var reportButton: UIButton?
    @IBOutlet private weak var chevronButton: UIButton?

    // MARK: - State
    weak var delegate: DonationActivityCellDelegate?
    private var donation: DonationActivityDonation?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Make the cell behave like a “card” with custom styling instead of default selection.
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // Most styling is defined in storyboard; this is a safe fallback.
        cardContainer?.backgroundColor = .white
    }

    // MARK: - Configure
    /// Populates the UI using a donation model. Called by the table view controller.
    func configure(with donation: DonationActivityDonation) {
        self.donation = donation

        // NGO logo (fallback icon when no custom image exists).
        logoImageView.image = donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        logoImageView.tintColor = DonationTheme.primaryBrown

        ngoNameLabel.text = donation.ngoName
        itemsLabel.text = donation.itemsDisplayText

        // Status is shown using both text and color to make it readable at a glance.
        statusLabel.text = donation.status.rawValue
        statusLabel.textColor = donation.status.color

        // Short date to keep the row compact.
        timestampLabel.text = donation.formattedShortDate
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset content so recycled cells never show old data while scrolling fast.
        donation = nil
        logoImageView.image = nil
        ngoNameLabel.text = nil
        itemsLabel.text = nil
        statusLabel.text = nil
        timestampLabel.text = nil
    }
}
