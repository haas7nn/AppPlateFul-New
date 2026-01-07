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
    }

    private func configureUI() {
        guard let donation else { return }

        title = donation.title
        donationDesc.text = donation.description
        donator.text = donation.donorName
        qty.text = donation.quantity
        icon.image = UIImage(systemName: donation.imageRef)

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

    private func formatDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df.string(from: date)
    }

    // MARK: - Actions

    @IBAction private func approveTapped(_ sender: UIButton) {
        updateStatusAndStore(newStatus: .toBeCollected)
        guard let donation else { return }

        NotificationService.shared.addEventNotification(
            to: donation.donorId,
            title: "Pickup Approved",
            message: "Your pickup time was approved for \(donation.title)."
        )


        showStatusAlert(
                  title: "Pickup time Approved",
                  message: nil,
                  systemImage: "checkmark.circle.fill",
                  color: .systemGreen
              )
    }

    @IBAction private func rejectTapped(_ sender: UIButton) {
        updateStatusAndStore(newStatus: .accepted)
        guard let donation else { return }

        NotificationService.shared.addEventNotification(
            to: donation.donorId,
            title: "Pickup Rejected",
            message: "Pickup time rejected. Please reschedule \(donation.title)."
        )

        showStatusAlert(
                   title: "Pickup time Rejected",
                   message: "Donor will be notified to reschedule",
                   systemImage: "xmark.circle.fill",
                   color: .systemRed
               )
    }

    // MARK: - Store update

    private func updateStatusAndStore(newStatus: DonationStatus) {
        guard let donation else { return }

        if newStatus == .toBeCollected {
            DonationService.shared.updatePickupApproval(donationId: donation.id, approved: true)
        } else if newStatus == .accepted {
            DonationService.shared.updatePickupApproval(donationId: donation.id, approved: false)
        }

        self.donation.status = newStatus
        if newStatus == .accepted { self.donation.scheduledPickup = nil }
        configureUI()
    }


    // MARK: - Alert

    private func showStatusAlert(
        title: String,
        message: String?,
        systemImage: String,
        color: UIColor
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let image = UIImage(systemName: systemImage)?
            .withTintColor(color, renderingMode: .alwaysOriginal)

        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        alert.view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 25),
            imageView.widthAnchor.constraint(equalToConstant: 40),
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let fullText: String
        if let message {
            fullText = "\n\n\n\(title)\n\(message)"
        } else {
            fullText = "\n\n\n\(title)"
        }

        let attributedTitle = NSAttributedString(
            string: fullText,
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
            ]
        )

        alert.setValue(attributedTitle, forKey: "attributedTitle")

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
