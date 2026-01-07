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


        // Store the selected donation before segue
        private var selectedDonation: Donation?

        override func viewDidLoad() {
            super.viewDidLoad()

            pickupTable.dataSource = self
            pickupTable.delegate = self
            title = "My Pickups"
            loadPickups()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            pickupTable.reloadData()
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

        // MARK: - UITableViewDataSource

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return pickups.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

            let cell = tableView.dequeueReusableCell(withIdentifier: "pickupCell", for: indexPath) as! MyPickupsTableViewCell
            let donation = pickups[indexPath.row]

            // Basic UI
            cell.titlelbl.text = donation.title
            cell.desclbl.text = donation.description
            cell.icon.image = UIImage(systemName: donation.imageRef)

            // Status button look
            configureStatusButton(cell.statusBtn, status: donation.status)

            // View Details button tap
            cell.ViewDetailsBtn.setTitle("View Details", for: .normal)
            cell.ViewDetailsBtn.addTarget(self, action: #selector(viewDetailsTapped(_:)), for: .touchUpInside)

            return cell
        }

        // MARK: - Button Tap

        @objc private func viewDetailsTapped(_ sender: UIButton) {

            // Find which row the button belongs to (SAFE, no tag)
            let point = sender.convert(CGPoint.zero, to: pickupTable)
            guard let indexPath = pickupTable.indexPathForRow(at: point) else { return }

            let donation = pickups[indexPath.row]
            selectedDonation = donation

            // Route based on status
            switch donation.status {
            case .accepted:
                performSegue(withIdentifier: "showAcceptedDetails", sender: self)

            case .toBeApproved:
                performSegue(withIdentifier: "showToBeApprovedDetails", sender: self)

            case .toBeCollected:
                performSegue(withIdentifier: "showToBeCollectedDetails", sender: self)

            default:
                // For now do nothing (you can add completed/cancelled later)
                break
            }
        }

        // MARK: - Navigation

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            guard let donation = selectedDonation else { return }

         
            if let vc = segue.destination as? AcceptedViewController {
                vc.donation = donation
                vc.hidesBottomBarWhenPushed = true
            }
            else if let vc = segue.destination as? ToBeApprovedViewController {
                vc.donation = donation
                vc.hidesBottomBarWhenPushed = true
            }
            else if let vc = segue.destination as? toBeCollectedViewController {
                vc.donation = donation
                vc.hidesBottomBarWhenPushed = true
            }
        }

        // MARK: - Status UI

        private func configureStatusButton(_ button: UIButton, status: DonationStatus) {
            button.configuration = nil

            button.isUserInteractionEnabled = false
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.lineBreakMode = .byTruncatingTail

            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.clipsToBounds = true

            switch status {
            case .accepted:
                button.setTitle("accepted", for: .normal)
                button.backgroundColor = .systemGreen

            case .toBeApproved:
                button.setTitle("To Be Approved", for: .normal)
                button.backgroundColor = .systemBlue

            case .toBeCollected:
                button.setTitle("To Be Collected", for: .normal)
                button.backgroundColor = .systemBlue

            default:
                button.setTitle(status.rawValue, for: .normal)
                button.backgroundColor = .systemGray
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
