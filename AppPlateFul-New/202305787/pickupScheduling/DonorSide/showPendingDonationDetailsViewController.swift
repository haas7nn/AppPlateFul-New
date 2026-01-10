//
//  showPendingDonationDetailsViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import UIKit

class showPendingDonationDetailsViewController: UIViewController {

    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var donationDesc: UILabel!
    
    
    
    @IBOutlet weak var donator: UILabel!
    
    @IBOutlet weak var qty: UILabel!
    
     @IBOutlet weak var exp: UILabel!
    
    var donation: Donation!

        override func viewDidLoad() {
            super.viewDidLoad()
            configureUI()
        }

        
        private func configureUI() {
            guard let donation else { return }

            title = "Donation Details"

            donator.text = "Loading…"

            UserService.shared.fetchUser(by: donation.donorId) { [weak self] user in
                DispatchQueue.main.async {
                    self?.donator.text = user?.name ?? "Unknown Donor"
                }
            }

            
            donationDesc.text = donation.description
            qty.text = donation.quantity
            loadDonorImage()

            if let expiry = donation.expiryDate {
                exp.text = formatDate(expiry)
            } else {
                exp.text = "—"
            }

            donationDesc.numberOfLines = 0
            donationDesc.lineBreakMode = .byWordWrapping
        }
    private func loadDonorImage() {
        guard let donation else { return }

        UserService.shared.fetchUserImage(userId: donation.donorId) { [weak self] imageRef in
            let name = imageRef ?? "person.circle.fill"
            self?.icon.image = UIImage(systemName: name)
        }
    }
        private func formatDate(_ date: Date) -> String {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .none
            return df.string(from: date)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


