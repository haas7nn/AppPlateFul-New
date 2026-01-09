//
//  AvailableDonationCell.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 25/12/2025.
//

import UIKit

class AvailableDonationCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var cardView: UIView!
    
    override func awakeFromNib() {
            super.awakeFromNib()

            cardView.layer.cornerRadius = 12
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOpacity = 0.15
            cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
            cardView.layer.shadowRadius = 6
        }

        func configure(with donation: Donation) {
            TitleLabel.text = donation.title
            subtitleLabel.text = donation.description
            iconImageView.image = UIImage(systemName: donation.imageRef)
            button.setTitle("View Details", for: .normal)
        }
    

}
