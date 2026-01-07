//
//  DonationSchedulingTableViewCell.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import UIKit

class DonationSchedulingTableViewCell: UITableViewCell {


        @IBOutlet weak var icon: UIImageView!
        @IBOutlet weak var titleLabel: UILabel!
        @IBOutlet weak var desc: UILabel!

        @IBOutlet weak var status: UIButton!
        @IBOutlet weak var actionButton: UIButton!

        override func awakeFromNib() {
            super.awakeFromNib()

            
            icon.layer.cornerRadius = 8
            icon.clipsToBounds = true

            
            status.isUserInteractionEnabled = false
            status.layer.cornerRadius = 10

            
            actionButton.layer.cornerRadius = 12
        }

        func configure(with donation: Donation) {
            titleLabel.text = donation.title
            desc.text = donation.description
            icon.image = UIImage(systemName: donation.imageRef)

            
            switch donation.status {
            case .pending:
                status.setTitle("Pending", for: .normal)
                status.backgroundColor = .systemOrange
                actionButton.setTitle("Schedule Pickup", for: .normal)
                actionButton.isEnabled = true
                actionButton.alpha = 1.0

            case .toBeApproved:
                status.setTitle("To Be Scheduled", for: .normal)
                status.backgroundColor = .systemBlue
                actionButton.setTitle("Schedule Pickup", for: .normal)
                actionButton.isEnabled = true
                actionButton.alpha = 1.0

            case .toBeCollected:
                status.setTitle("To Be Collected", for: .normal)
                status.backgroundColor = .systemGreen
                actionButton.setTitle("View Details", for: .normal)
                actionButton.isEnabled = true
                actionButton.alpha = 1.0

            default:
               
                status.setTitle("—", for: .normal)
                status.backgroundColor = .systemGray
                actionButton.setTitle("—", for: .normal)
                actionButton.isEnabled = false
                actionButton.alpha = 0.6
            }
        }
    

    


  

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
