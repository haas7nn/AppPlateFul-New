//
//  AvailableDonationsViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 25/12/2025.
//

import UIKit

class AvailableDonationsViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    
    
    private var availableDonations: [Donation] = []


       override func viewDidLoad() {
           super.viewDidLoad()
           tableView.dataSource = self
           title = "Available Donations"
           loadAvailableDonations()
       }
    
    private func loadAvailableDonations() {
        DonationService.shared.fetchByStatus(.pending) { [weak self] items in
            guard let self = self else { return }
            self.availableDonations = items
            self.tableView.reloadData()
        }
    }

    
        override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
         }


       // MARK: - UITableViewDataSource

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return availableDonations.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let cell = tableView.dequeueReusableCell(withIdentifier: "donation", for: indexPath) as! AvailableDonationCell
           let donation = availableDonations[indexPath.row]

           cell.TitleLabel.text = donation.title
           cell.subtitleLabel.text = donation.description
           cell.iconImageView.image = UIImage(systemName: donation.imageRef)

           cell.button.setTitle("View Details", for: .normal)
           cell.button.addTarget(self, action: #selector(donateNowTapped(_:)), for: .touchUpInside)

           return cell
       }

       // MARK: - Navigation

       @objc private func donateNowTapped(_ sender: UIButton) {
           
              let buttonPosition = sender.convert(CGPoint.zero, to: tableView)

              guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else {
                  return
              }

              performSegue(withIdentifier: "showDonationDetails", sender: indexPath)
       }

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "showDonationDetails" {
                  guard let detailsVC = segue.destination as? AcceptAvailableDonationDetailsViewController else { return }
                  guard let indexPath = sender as? IndexPath else { return }

                  let donation = availableDonations[indexPath.row]
                  detailsVC.donation = donation
                  detailsVC.hidesBottomBarWhenPushed = true
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
