//
//  DonationActivityCell.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Delegate protocol for handling report action from the cell
protocol DonationActivityCellDelegate: AnyObject {
    func didTapReport(for donation: DonationActivityDonation)
}

// Custom table view cell for displaying donation activity details
class DonationActivityCell: UITableViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cardContainer: UIView!
    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var ngoNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var statusDetailLabel: UILabel!
    @IBOutlet weak var pickupDateLabel: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: DonationActivityCellDelegate?
    private var donation: DonationActivityDonation?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    // Configures UI styling for the cell
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = DonationTheme.backgroundColor
        
        cardContainer.layer.cornerRadius = 22
        cardContainer.backgroundColor = DonationTheme.cardBackground
        
        logoContainer.layer.cornerRadius = 12
        logoContainer.backgroundColor = .white
        
        reportButton.addTarget(self, action: #selector(reportTapped), for: .touchUpInside)
    }
    
    // MARK: - Configuration
    // Populates cell with donation activity data
    func configure(with donation: DonationActivityDonation) {
        self.donation = donation
        
        logoImageView.image = donation.ngoLogo ?? UIImage(systemName: "building.2.fill")
        logoImageView.tintColor = DonationTheme.primaryBrown
        
        ngoNameLabel.text = donation.ngoName
        statusLabel.text = donation.status.rawValue
        statusLabel.textColor = donation.status.color
        timestampLabel.text = donation.formattedCreatedDate
        
        itemsLabel.text = "Items: \(donation.itemsDisplayText)"
        statusDetailLabel.text = "Status: \(donation.status.rawValue)"
        
        if let pickupDate = donation.formattedPickupDate {
            pickupDateLabel.text = "Pickup Date: \(pickupDate)"
            pickupDateLabel.isHidden = false
        } else {
            pickupDateLabel.isHidden = true
        }
        
        reportButton.alpha = donation.isReported ? 0.5 : 1.0
        reportButton.isEnabled = !donation.isReported
    }
    
    // MARK: - Actions
    // Notifies delegate when report button is tapped
    @objc private func reportTapped() {
        guard let donation else { return }
        delegate?.didTapReport(for: donation)
    }
    
    // Resets UI content before cell reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        ngoNameLabel.text = nil
        statusLabel.text = nil
        timestampLabel.text = nil
        itemsLabel.text = nil
        statusDetailLabel.text = nil
        pickupDateLabel.text = nil
        pickupDateLabel.isHidden = false
    }
}
