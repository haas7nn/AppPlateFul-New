//
//  AcceptAvailableDonationDetailsViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 25/12/2025.
//

import UIKit

class AcceptAvailableDonationDetailsViewController: UIViewController {

    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var donationDesc: UILabel!
    
    @IBOutlet weak var acceptDonationbtn: UIButton!
    
    @IBOutlet weak var donator: UILabel!
    
    @IBOutlet weak var qty: UILabel!
    
     @IBOutlet weak var exp: UILabel!
    
    var donation: Donation!

       override func viewDidLoad() {
           super.viewDidLoad()
           configureUI()
           loadDonorImage()
         
       }
    private func configureUI() {
        title = "Donation Details"

        // Fill UI from donation
        donator.text = donation.donorName
        donationDesc.text = donation.description
        qty.text = donation.quantity
        

        // Expiry formatting (safe)
        if let expiry = donation.expiryDate {
            exp.text = DateFormatter.dmy.string(from: expiry)
        } else {
            exp.text = "N/A"
        }

        // Optional: wrap description
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

    @IBAction func acceptDonationTapped(_ sender: Any) {
        
        guard donation != nil else { return }

               // Store ngoId (simple)
               let currentNgoId = UserDefaults.standard.string(forKey: "currentUserId")
               if let currentNgoId, !currentNgoId.isEmpty {
                   donation.ngoId = currentNgoId
               }

               // Update status in Firestore
               DonationService.shared.updateStatus(donationId: donation.id, status: .accepted) { [weak self] _ in
                   guard let self = self else { return }

                   // Update local object
                   self.donation.status = .accepted

                   // Notifications (same as your logic)
                   NotificationService.shared.addEventNotification(
                       to: self.donation.donorId,
                       title: "Donation Accepted",
                       message: "An NGO accepted your donation: \(self.donation.title)."
                   )

                   if let ngoId = self.donation.ngoId {
                       NotificationService.shared.addEventNotification(
                           to: ngoId,
                           title: "Donation Accepted",
                           message: "You accepted a donation: \(self.donation.title)."
                       )
                   }

                   // Show alert (same style, now consistent)
                   self.showIconAlert(
                       title: "Donation Accepted",
                       systemImage: "checkmark.circle.fill",
                       color: .systemGreen
                   )
               }
           }

           // MARK: - Simple alert helper
           private func showIconAlert(title: String, systemImage: String, color: UIColor) {
               let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

               let image = UIImage(systemName: systemImage)?
                   .withTintColor(color, renderingMode: .alwaysOriginal)

               let imageView = UIImageView(image: image)
               imageView.translatesAutoresizingMaskIntoConstraints = false
               imageView.contentMode = .scaleAspectFit
               alert.view.addSubview(imageView)

               NSLayoutConstraint.activate([
                   imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                   imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 30),
                   imageView.widthAnchor.constraint(equalToConstant: 40),
                   imageView.heightAnchor.constraint(equalToConstant: 40)
               ])

               let paragraphStyle = NSMutableParagraphStyle()
               paragraphStyle.alignment = .center

               let attributedTitle = NSAttributedString(
                   string: "\n\n\n\(title)",
                   attributes: [
                       .paragraphStyle: paragraphStyle,
                       .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
                   ]
               )

               alert.setValue(attributedTitle, forKey: "attributedTitle")

               alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                   self.navigationController?.popViewController(animated: true)
               })

               present(alert, animated: true)
           }
       }

   // MARK: - Date Formatter Helper
private extension DateFormatter {
    static let dmy: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yyyy"
        return df
    }()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
