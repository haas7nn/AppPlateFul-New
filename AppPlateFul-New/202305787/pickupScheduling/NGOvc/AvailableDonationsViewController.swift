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

           title = "Available Donations"
           tableView.dataSource = self

           loadAvailableDonations()
       }

       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           loadAvailableDonations()
       }

       private func loadAvailableDonations() {
           DonationService.shared.fetchByStatus(.pending) { [weak self] items in
               guard let self = self else { return }
               self.availableDonations = items
               self.tableView.reloadData()
           }
       }

      

       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           availableDonations.count
       }

       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

           let cell = tableView.dequeueReusableCell(withIdentifier: "donation", for: indexPath) as! AvailableDonationCell
           let donation = availableDonations[indexPath.row]

           cell.TitleLabel.text = donation.title
           cell.subtitleLabel.text = donation.description
           cell.iconImageView.image = UIImage(systemName: "photo") // placeholder
           
           ImageLoader.shared.load(donation.imageRef) { image in
               DispatchQueue.main.async {
                   // Avoid wrong image due to cell reuse
                   if let currentIndexPath = tableView.indexPath(for: cell),
                      currentIndexPath == indexPath {
                       cell.iconImageView.image = image ?? UIImage(systemName: "photo")
                   }
               }
           }

           cell.button.setTitle("View Details", for: .normal)

           // Important: remove old targets because cells are reused
           cell.button.removeTarget(nil, action: nil, for: .allEvents)
           cell.button.addTarget(self, action: #selector(donateNowTapped(_:)), for: .touchUpInside)

           return cell
       }

      

       @objc private func donateNowTapped(_ sender: UIButton) {
           
           let point = sender.convert(CGPoint.zero, to: tableView)
                   guard let indexPath = tableView.indexPathForRow(at: point) else { return }

                   performSegue(withIdentifier: "showDonationDetails", sender: indexPath)
               }

               override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                   guard segue.identifier == "showDonationDetails" else { return }
                   guard let detailsVC = segue.destination as? AcceptAvailableDonationDetailsViewController else { return }
                   guard let indexPath = sender as? IndexPath else { return }

                   detailsVC.donation = availableDonations[indexPath.row]
                   detailsVC.hidesBottomBarWhenPushed = true
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
