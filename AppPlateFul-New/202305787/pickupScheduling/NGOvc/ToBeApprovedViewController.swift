//
//  ToBeApprovedViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 28/12/2025.
//

import UIKit

final class ToBeApprovedViewController: UIViewController {

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var donationDesc: UILabel!
    @IBOutlet private weak var donator: UILabel!
    @IBOutlet private weak var qty: UILabel!
    @IBOutlet private weak var exp: UILabel!

    @IBOutlet private weak var address: UILabel!
    @IBOutlet private weak var time: UILabel!
    @IBOutlet private weak var date: UILabel!

    @IBOutlet private weak var approveBtn: UIButton!
    
    @IBOutlet private weak var rejectBtn: UIButton!
    
    
    var donation: Donation!

       override func viewDidLoad() {
           super.viewDidLoad()
           configureUI()
           loadDonorImage()
       }

     
       private func configureUI() {
           guard let donation else { return }

           title = donation.title
           donationDesc.text = donation.description
           donator.text = "Loading…"

           UserService.shared.fetchUser(by: donation.donorId) { [weak self] user in
               DispatchQueue.main.async {
                   self?.donator.text = user?.name ?? "Unknown Donor"
               }
           }

           qty.text = donation.quantity
          

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

           approveBtn.layer.cornerRadius = 12
           rejectBtn.layer.cornerRadius = 12
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
  

    @IBAction private func approveTapped(_ sender: UIButton) {
        guard let donation else { return }

               
               DonationService.shared.updatePickupApproval(donationId: donation.id, approved: true) { [weak self] _ in
                   guard let self = self else { return }

                   // Update local
                   self.donation.status = .toBeCollected
                   self.configureUI()

                   // Notify donor
                   NotificationService.shared.addEventNotification(
                       to: donation.donorId,
                       title: "Pickup Approved",
                       message: "Your pickup time was approved for \(donation.title)."
                   )

                   // Show confirmation
                   self.showIconAlert(
                       title: "Pickup time Approved",
                       message: nil,
                       systemImage: "checkmark.circle.fill",
                       color: .systemGreen
                   )
               }
           }

    @IBAction private func rejectTapped(_ sender: UIButton) {
        guard let donation else { return }

               // Update Firestore
               DonationService.shared.updatePickupApproval(donationId: donation.id, approved: false) { [weak self] _ in
                   guard let self = self else { return }

                   // Update local
                   self.donation.status = .accepted
                   self.donation.scheduledPickup = nil
                   self.configureUI()

                   // Notify donor
                   NotificationService.shared.addEventNotification(
                       to: donation.donorId,
                       title: "Pickup Rejected",
                       message: "Pickup time rejected. Please reschedule \(donation.title)."
                   )

                   // Show rejection
                   self.showIconAlert(
                       title: "Pickup time Rejected",
                       message: "Donor will be notified to reschedule",
                       systemImage: "xmark.circle.fill",
                       color: .systemRed
                   )
               }
    }

    

       private func showIconAlert(
           title: String,
           message: String?,
           systemImage: String,
           color: UIColor
       ) {
           let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)

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

           if let message {
               let attributedMessage = NSAttributedString(
                   string: message,
                   attributes: [
                       .paragraphStyle: paragraphStyle,
                       .font: UIFont.systemFont(ofSize: 13, weight: .regular)
                   ]
               )
               alert.setValue(attributedMessage, forKey: "attributedMessage")
           }

           alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
               self.navigationController?.popViewController(animated: true)
           })

           present(alert, animated: true)
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
