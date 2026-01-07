//
//  showPickupInfoDetailsViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import UIKit

class showPickupInfoDetailsViewController: UIViewController {

    @IBOutlet private weak var icon: UIImageView!
        @IBOutlet private weak var donationDesc: UILabel!
        @IBOutlet private weak var donator: UILabel!
        @IBOutlet private weak var qty: UILabel!
        @IBOutlet private weak var exp: UILabel!
        @IBOutlet private weak var address: UILabel!
        @IBOutlet private weak var time: UILabel!
        @IBOutlet private weak var date: UILabel!

        var donation: Donation!

        override func viewDidLoad() {
            super.viewDidLoad()
            configureUI()
        }

        private func configureUI() {
            guard let donation else { return }

            title = donation.title
            donationDesc.text = donation.description
            donator.text = donation.donorName
            qty.text = donation.quantity

            icon.image = UIImage(systemName: donation.imageRef)

            // expiryDate is optional
            if let expiry = donation.expiryDate {
                exp.text = formatDate(expiry)
            } else {
                exp.text = "—"
            }

            if let pickup = donation.scheduledPickup {
                address.text = pickup.pickupLocation
                time.text = pickup.pickupTimeRange
                date.text = formatDate(pickup.pickupDate)
            } else {
                address.text = "—"
                time.text = "—"
                date.text = "—"
            }

            
        }

        private func formatDate(_ date: Date) -> String {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return df.string(from: date)
        }

        

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
