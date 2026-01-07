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

          cardView.layer.cornerRadius = 12
          cardView.layer.masksToBounds = false

          cardView.layer.shadowColor = UIColor.black.cgColor
          cardView.layer.shadowOpacity = 0.15
          cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
          cardView.layer.shadowRadius = 6
      }

      override func layoutSubviews() {
          super.layoutSubviews()

          cardView.layer.shadowPath = UIBezierPath(
              roundedRect: cardView.bounds,
              cornerRadius: 12
          ).cgPath
      }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
