//
//  MyPickupsTableViewCell.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 28/12/2025.
//

import UIKit

class MyPickupsTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var desclbl: UILabel!
    @IBOutlet weak var ViewDetailsBtn: UIButton!
    @IBOutlet weak var statusBtn: UIButton!
    
    @IBOutlet weak var cardView: UIView!
    
    
    
    override func awakeFromNib() {
          super.awakeFromNib()
        
        statusBtn.configuration = nil
        

        
          cardView.layer.cornerRadius = 12
          cardView.layer.shadowColor = UIColor.black.cgColor
          cardView.layer.shadowOpacity = 0.15
          cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
          cardView.layer.shadowRadius = 6

          statusBtn.isUserInteractionEnabled = false
          statusBtn.layer.cornerRadius = 12
          statusBtn.clipsToBounds = true
          statusBtn.setTitleColor(.white, for: .normal)
          statusBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            statusBtn.titleLabel?.adjustsFontSizeToFitWidth = true
            statusBtn.titleLabel?.minimumScaleFactor = 0.6
            statusBtn.titleLabel?.numberOfLines = 1

      }

      func configure(with donation: Donation) {
          titlelbl.text = donation.title
          desclbl.text = donation.description
          icon.image = UIImage(systemName: donation.imageRef)
          ViewDetailsBtn.setTitle("View Details", for: .normal)

          configureStatus(status: donation.status)
      }

      private func configureStatus(status: DonationStatus) {
          switch status {
          case .accepted:
              statusBtn.setTitle("To Be Scheduled", for: .normal)
              statusBtn.backgroundColor = .systemBlue

          case .toBeApproved:
              statusBtn.setTitle("To Be Approved", for: .normal)
              statusBtn.backgroundColor = .systemBlue

          case .toBeCollected:
              statusBtn.setTitle("To Be Collected", for: .normal)
              statusBtn.backgroundColor = .systemGreen

          default:
              statusBtn.setTitle(status.rawValue, for: .normal)
              statusBtn.backgroundColor = .systemGray
          }
      }
    

}
