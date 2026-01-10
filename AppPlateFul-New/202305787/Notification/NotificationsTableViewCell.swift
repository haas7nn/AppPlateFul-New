//
//  NotificationsTableViewCell.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
           super.awakeFromNib()
        // card look
           cardView.layer.cornerRadius = 12
           cardView.layer.shadowColor = UIColor.black.cgColor
           cardView.layer.shadowOpacity = 0.15
           cardView.layer.shadowOffset = CGSize(width: 0, height: 4)
           cardView.layer.shadowRadius = 6
        // icon shape
           iconImageView.layer.cornerRadius = 20
           iconImageView.clipsToBounds = true
       }
        //load data into the cells 
       func configure(title: String, message: String, time: String, iconName: String) {
           titleLabel.text = title
           messageLabel.text = message
           timeLabel.text = time
           iconImageView.image = UIImage(systemName: iconName)
       }

}
