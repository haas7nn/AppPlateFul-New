//
//  DonationSchedulingViewController.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import UIKit

class DonationSchedulingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    private var donations: [Donation] = []


    private var selectedDonation: Donation?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        navigationController?.setNavigationBarHidden(false, animated: true)
        title = "My Donations"
        loadDonations()
    }
    
    private func loadDonations() {
        DonationService.shared.fetchAll { [weak self] items in
            guard let self = self else { return }

            self.donations = items.filter {
                $0.status == .pending ||
                $0.status == .accepted ||
                $0.status == .toBeApproved ||
                $0.status == .toBeCollected
            }

            self.tableView.reloadData()
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "DonationSchedulingCell", for: indexPath) as! DonationSchedulingTableViewCell
        let donation = donations[indexPath.row]

        cell.titleLabel.text = donation.title
        cell.desc.text = donation.description
        cell.icon.image = UIImage(systemName: donation.imageRef)

        configureStatusButton(cell.status, status: donation.status)

        cell.actionButton.setTitle("View Details", for: .normal)
        cell.actionButton.addTarget(self, action: #selector(viewDetailsTapped(_:)), for: .touchUpInside)

        return cell
    }

    @objc private func viewDetailsTapped(_ sender: UIButton) {

        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }

        let donation = donations[indexPath.row]
        selectedDonation = donation

        switch donation.status {
        case .pending:
            performSegue(withIdentifier: "showPendingDonationDetailsViewController", sender: self)

        case .accepted:
            performSegue(withIdentifier: "DonationSchedulingPageViewController", sender: self)

        case .toBeApproved, .toBeCollected:
            performSegue(withIdentifier: "showPickupInfoDetailsViewController", sender: self)

        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let donation = selectedDonation else { return }

            if let vc = segue.destination as? showPendingDonationDetailsViewController {
                vc.donation = donation
            }
            else if let vc = segue.destination as? DonationSchedulingPageViewController {
                vc.donation = donation
            }
            else if let vc = segue.destination as? showPickupInfoDetailsViewController {
                vc.donation = donation
            }
    }

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
        case .pending:
            button.setTitle("Pending", for: .normal)
            button.backgroundColor = .systemGreen

        case .accepted:
            button.setTitle("To Be Scheduled", for: .normal)
            button.backgroundColor = .systemBlue

        case .toBeApproved, .toBeCollected:
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
