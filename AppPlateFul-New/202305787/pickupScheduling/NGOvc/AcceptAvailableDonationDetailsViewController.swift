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

        
        donator.text = "Loading…"

        UserService.shared.fetchUser(by: donation.donorId) { [weak self] user in
            DispatchQueue.main.async {
                self?.donator.text = user?.name ?? "Unknown Donor"
            }
        }

        donationDesc.text = donation.description
        qty.text = donation.quantity
        

        
        if let expiry = donation.expiryDate {
            exp.text = DateFormatter.dmy.string(from: expiry)
        } else {
            exp.text = "N/A"
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

    @IBAction func acceptDonationTapped(_ sender: Any) {
        
        guard let donation else { return }
           guard let ngoId = UserSession.shared.userId else { return }

           
           DonationService.shared.assignNgoAndUpdateStatus(
               donationId: donation.id,
               ngoId: ngoId,
               status: .accepted
           ) { [weak self] ok in
               guard let self = self, ok else { return }

               self.donation.ngoId = ngoId
               self.donation.status = .accepted

               NotificationService.shared.addEventNotification(
                   to: self.donation.donorId,
                   title: "Donation Accepted",
                   message: "An NGO accepted your donation: \(self.donation.title)."
               )

               self.showIconAlert(
                   title: "Donation Accepted",
                   systemImage: "checkmark.circle.fill",
                   color: .systemGreen
               )
           }
           }

           
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
