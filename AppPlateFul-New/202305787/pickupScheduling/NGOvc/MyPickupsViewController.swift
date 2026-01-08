//
//  MyPickupsViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 28/12/2025.
//

import UIKit

class MyPickupsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var pickupTable: UITableView!
    
    
    private var pickups: [Donation] = []
       private var selectedDonation: Donation?

       override func viewDidLoad() {
           super.viewDidLoad()

           title = "My Pickups"
           pickupTable.dataSource = self
           pickupTable.delegate = self

           loadPickups()
       }

       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           loadPickups()
       }

       private func loadPickups() {
           DonationService.shared.fetchAll { [weak self] items in
               guard let self = self else { return }

               self.pickups = items.filter {
                   $0.status == .accepted ||
                   $0.status == .toBeApproved ||
                   $0.status == .toBeCollected
               }

               self.pickupTable.reloadData()
           }
       }

       // MARK: - Table

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           pickups.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let cell = tableView.dequeueReusableCell(withIdentifier: "pickupCell", for: indexPath) as! MyPickupsTableViewCell
           let donation = pickups[indexPath.row]

           cell.titlelbl.text = donation.title
           cell.desclbl.text = donation.description
           cell.icon.image = UIImage(systemName: donation.imageRef)
           cell.ViewDetailsBtn.setTitle("View Details", for: .normal)
           cell.configure(with: donation)
           cell.ViewDetailsBtn.removeTarget(nil, action: nil, for: .allEvents)
           cell.ViewDetailsBtn.addTarget(self, action: #selector(viewDetailsTapped(_:)), for: .touchUpInside)

           return cell
       }

        // MARK: - Button Tap

        @objc private func viewDetailsTapped(_ sender: UIButton) {

            let point = sender.convert(CGPoint.zero, to: pickupTable)
                  guard let indexPath = pickupTable.indexPathForRow(at: point) else { return }

                  selectedDonation = pickups[indexPath.row]

                  switch selectedDonation?.status {
                  case .accepted:
                      performSegue(withIdentifier: "showAcceptedDetails", sender: self)
                  case .toBeApproved:
                      performSegue(withIdentifier: "showToBeApprovedDetails", sender: self)
                  case .toBeCollected:
                      performSegue(withIdentifier: "showToBeCollectedDetails", sender: self)
                  default:
                      break
                  }
              }

              override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                  guard let donation = selectedDonation else { return }

                  if let vc = segue.destination as? AcceptedViewController {
                      vc.donation = donation
                      vc.hidesBottomBarWhenPushed = true
                  } else if let vc = segue.destination as? ToBeApprovedViewController {
                      vc.donation = donation
                      vc.hidesBottomBarWhenPushed = true
                  } else if let vc = segue.destination as? toBeCollectedViewController {
                      vc.donation = donation
                      vc.hidesBottomBarWhenPushed = true
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

}
