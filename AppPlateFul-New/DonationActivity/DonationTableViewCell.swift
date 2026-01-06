//
//  DonationTableViewCell.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Simple table view cell for displaying donation summary information
class DonationTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var logoImageView: UIImageView?
    @IBOutlet weak var ngoNameLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // MARK: - Setup
    // Configures base UI appearance
    private func setupUI() {
        logoImageView?.layer.cornerRadius = 10
        logoImageView?.clipsToBounds = true
    }
    
    // MARK: - Configuration
    // Populates the cell with donation data
    func configure(with donation: DonationActivityDonation) {
        logoImageView?.image =
            donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        logoImageView?.tintColor = DonationTheme.primaryBrown
        
        ngoNameLabel?.text = donation.ngoName
        statusLabel?.text = donation.status.rawValue
        statusLabel?.textColor = donation.status.color
        dateLabel?.text = donation.formattedCreatedDate
    }
    
    // Resets content before cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView?.image = nil
        ngoNameLabel?.text = nil
        statusLabel?.text = nil
        dateLabel?.text = nil
    }
}
