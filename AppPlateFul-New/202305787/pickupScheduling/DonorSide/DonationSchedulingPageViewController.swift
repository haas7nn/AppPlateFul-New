//
//  DonationSchedulingPageViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import UIKit

class DonationSchedulingPageViewController: UIViewController {
    
   

    @IBOutlet weak var date: UIDatePicker!
    
    @IBOutlet weak var time: UITextField!
    
    @IBOutlet weak var location: UITextField!
    
    @IBOutlet weak var confirmbtn: UIButton!
    
    var donation: Donation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
           title = "Schedule Pickup"
           
    }
    
    @IBAction func confirm(_ sender: Any) {
        guard let donation else { return }

                let timeText = time.text ?? ""
                let locationText = location.text ?? ""

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

                DonationService.shared.attachPickupSchedule(
                    donationId: donation.id,
                    pickup: schedule
                ) { [weak self] _ in
                    guard let self = self else { return }

                    if let ngoId = donation.ngoId {
                        NotificationService.shared.addEventNotification(
                            to: ngoId,
                            title: "Pickup Scheduled",
                            message: "Pickup was scheduled for \(donation.title)."
                        )
                    }

                    self.showIconAlert(
                        title: "Pickup Scheduled",
                        systemImage: "checkmark.circle.fill",
                        color: .systemGreen
                    )
                }
            }

            // Simple validation alert
            private func showSimpleAlert(message: String) {
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }

            // Standard success alert 
            private func showIconAlert(
                title: String,
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
        
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
