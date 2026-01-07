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
        title = "Donation Details"
        
        
        donator.text = donation.donorName
        donationDesc.text = donation.description
        qty.text = donation.quantity
        icon.image = UIImage(systemName: donation.imageRef)
        
        
        if let expiry = donation.expiryDate {
            exp.text = DateFormatter.dmy.string(from: expiry)
        } else {
            exp.text = "N/A"
        }
        
        
        donationDesc.numberOfLines = 0
        donationDesc.lineBreakMode = .byWordWrapping
    }
       }
    
      
    private extension DateFormatter {
        static let dmy: DateFormatter = {
            let df = DateFormatter()
            df.dateFormat = "dd-MM-yyyy"
            return df
        }()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


