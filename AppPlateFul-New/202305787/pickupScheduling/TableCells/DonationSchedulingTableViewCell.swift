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
    @IBOutlet weak var cardView: UIView!
    

    override func awakeFromNib() {
           super.awakeFromNib()

           // Card style 
           cardView.layer.cornerRadius = 12
           cardView.layer.shadowColor = UIColor.black.cgColor
           cardView.layer.shadowOpacity = 0.15
           cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
           cardView.layer.shadowRadius = 6

           // Icon style
           icon.layer.cornerRadius = 8
           icon.clipsToBounds = true

           // Status badge
           status.isUserInteractionEnabled = false
           status.layer.cornerRadius = 10
           status.clipsToBounds = true

           // Action button
           actionButton.layer.cornerRadius = 12
           actionButton.clipsToBounds = true
       }

       func configure(with donation: Donation) {
           titleLabel.text = donation.title
           desc.text = donation.description
           icon.image = UIImage(systemName: donation.imageRef)

           actionButton.isEnabled = true
           actionButton.alpha = 1.0

           switch donation.status {

           case .pending:
               status.setTitle("Pending", for: .normal)
               status.backgroundColor = .systemOrange
               actionButton.setTitle("View Details", for: .normal)

           case .accepted:
               status.setTitle("To Be Scheduled", for: .normal)
               status.backgroundColor = .systemBlue
               actionButton.setTitle("Schedule Pickup", for: .normal)

           case .toBeApproved:
               status.setTitle("To Be Approved", for: .normal)
               status.backgroundColor = .systemBlue
               actionButton.setTitle("View Details", for: .normal)

           case .toBeCollected:
               status.setTitle("To Be Collected", for: .normal)
               status.backgroundColor = .systemGreen
               actionButton.setTitle("View Details", for: .normal)

           default:
               status.setTitle("—", for: .normal)
               status.backgroundColor = .systemGray
               actionButton.setTitle("—", for: .normal)
               actionButton.isEnabled = false
               actionButton.alpha = 0.6
           }
       }

}
