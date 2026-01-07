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
           title = "Donation Details"

           // Fill UI from donation
           donator.text = donation.donorName
           donationDesc.text = donation.description
           qty.text = donation.quantity
           icon.image = UIImage(systemName: donation.imageRef)

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

    @IBAction func acceptDonationTapped(_ sender: Any) {
        
        guard let donation else { return }

               let currentNgoId = UserDefaults.standard.string(forKey: "currentUserId")
               if let currentNgoId, !currentNgoId.isEmpty {
                   self.donation.ngoId = currentNgoId
               }

               DonationService.shared.updateStatus(donationId: donation.id, status: .accepted) { _ in
               }

               NotificationService.shared.addEventNotification(
                   to: donation.donorId,
                   title: "Donation Accepted",
                   message: "An NGO accepted your donation: \(donation.title)."
               )

               if let ngoId = self.donation.ngoId {
                   NotificationService.shared.addEventNotification(
                       to: ngoId,
                       title: "Donation Accepted",
                       message: "You accepted a donation: \(donation.title)."
                   )
               }

               self.donation.status = .accepted

               let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

               let image = UIImage(systemName: "checkmark.circle.fill")?
                   .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)

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
                   string: "\n\n\nDonation Accepted",
                   attributes: [
                       .paragraphStyle: paragraphStyle,
                       .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
                   ]
               )

               alert.setValue(attributedTitle, forKey: "attributedTitle")

               let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                   self.navigationController?.popViewController(animated: true)
               }

               alert.addAction(okAction)
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
