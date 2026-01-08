//
//  DonationActivityCell.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

protocol DonationActivityCellDelegate: AnyObject {
    func didTapReport(for donation: DonationActivityDonation)
}

class DonationActivityCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var ngoNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    
    // Hidden/unused outlets (kept for storyboard compatibility)
    @IBOutlet weak var statusDetailLabel: UILabel?
    @IBOutlet weak var pickupDateLabel: UILabel?
    @IBOutlet weak var reportButton: UIButton?
    @IBOutlet weak var chevronButton: UIButton?
    
    // MARK: - Properties
    weak var delegate: DonationActivityCellDelegate?
    private var donation: DonationActivityDonation?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        // Card styling is handled in storyboard
        cardContainer?.backgroundColor = .white
    }
    
    // MARK: - Configuration
    func configure(with donation: DonationActivityDonation) {
        self.donation = donation
        
        // Logo
        logoImageView.image = donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        logoImageView.tintColor = DonationTheme.primaryBrown
        
        // NGO Name
        ngoNameLabel.text = donation.ngoName
        
        // Items
        itemsLabel.text = donation.itemsDisplayText
        
        // Status
        statusLabel.text = donation.status.rawValue
        statusLabel.textColor = donation.status.color
        
        // Timestamp (short format)
        timestampLabel.text = donation.formattedShortDate
    }
    
    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        ngoNameLabel.text = nil
        itemsLabel.text = nil
        statusLabel.text = nil
        timestampLabel.text = nil
    }
}
