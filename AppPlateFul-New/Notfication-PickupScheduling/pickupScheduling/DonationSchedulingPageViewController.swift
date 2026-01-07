//
//  DonationSchedulingPageViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import UIKit

class DonationSchedulingPageViewController: UIViewController {
    
    var donation: Donation!

    @IBOutlet weak var date: UIDatePicker!
    
    @IBOutlet weak var time: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var confirmbtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
           title = "Schedule Pickup"
           confirmbtn.layer.cornerRadius = 12
    }
    
    @IBAction func confirm(_ sender: Any) {
        guard let donation else { return }

           let timeText = (time.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
           let locationText = (location.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

           if timeText.isEmpty || locationText.isEmpty {
               showSimpleAlert(message: "Please enter pickup time and location.")
               return
           }

           let schedule = PickupSchedule(
               id: UUID().uuidString,
               donationId: donation.id,
               pickupDate: date.date,
               pickupTimeRange: timeText,
               pickupLocation: locationText
           )

           DonationService.shared.attachPickupSchedule(donationId: donation.id, pickup: schedule) { _ in
           }
            if let ngoId = donation.ngoId {
            NotificationService.shared.addEventNotification(
                to: ngoId,
                title: "Pickup Scheduled",
                message: "Pickup was scheduled for \(donation.title)."
            )
                }
        

           self.donation.scheduledPickup = schedule
           self.donation.status = .toBeApproved

           showSuccessAlertAndPop()
       }
    private func showSimpleAlert(message: String) {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        private func showSuccessAlertAndPop() {
            let alert = UIAlertController(title: nil, message: "Pickup scheduled successfully.", preferredStyle: .alert)

            let image = UIImage(systemName: "checkmark.circle.fill")?
                .withTintColor(.systemGreen, renderingMode: .alwaysOriginal)

            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit

            alert.view.addSubview(imageView)

            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                imageView.topAnchor.constraint(equalTo: alert.view.topAnchor, constant: 20),
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 40)
            ])

            let spacer = UIViewController()
            spacer.preferredContentSize = CGSize(width: 1, height: 20)
            alert.setValue(spacer, forKey: "contentViewController")

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
