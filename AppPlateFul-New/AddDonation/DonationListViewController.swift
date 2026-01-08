import UIKit

class DonationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var donations: [Donation] = []
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy – h:mm a"
        return f
    }()
    
    // TODO: set this from your logged-in user
    private var currentDonorId: String {
        // e.g. Auth.auth().currentUser?.uid ?? ""
        return "CURRENT_USER_ID"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My Donations"
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Show nav bar on this screen
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        reloadData()
    }
    
    private func reloadData() {
        DonationService.shared.fetchForDonor(donorId: currentDonorId) { [weak self] items in
            DispatchQueue.main.async {
                self?.donations = items
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
        }
    }
    
    private func updateEmptyState() {
        if donations.isEmpty {
            let label = UILabel()
            label.text = "You have no donations yet!"
            label.textColor = UIColor(white: 0.4, alpha: 1.0)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 16)
            tableView.backgroundView = label
        } else {
            tableView.backgroundView = nil
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return donations.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseId = "DonationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        
        let donation = donations[indexPath.row]
        
        // quantity is String in your model
        cell.textLabel?.text = "\(donation.quantity)x \(donation.title)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Show expiry date if available
        let dateString: String
        if let exp = donation.expiryDate {
            dateString = dateFormatter.string(from: exp)
        } else {
            dateString = "-"
        }
        
        let ngoName = donation.ngoId ?? "Unknown NGO"
        cell.detailTextLabel?.text = "To: \(ngoName) • Exp: \(dateString)"
        cell.detailTextLabel?.textColor = UIColor(white: 0.45, alpha: 1.0)
        cell.detailTextLabel?.numberOfLines = 2
        
        // Show arrow if there are notes/description
        cell.accessoryType = donation.description.isEmpty ? .none : .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate (tap to see notes/description)
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let donation = donations[indexPath.row]
        guard !donation.description.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Notes",
            message: donation.description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
