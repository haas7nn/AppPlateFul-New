import UIKit

// Shows a list of donations that belong to the current donor.
class DonationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Array that holds all donations loaded from Firestore
    private var donations: [Donation] = []
    
    // Formats dates nicely for the list cell subtitle
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy – h:mm a"
        return f
    }()
    
    // ID of the currently logged in donor.
    // TODO: replace the hard-coded string with your real user id from Auth.
    private var currentDonorId: String {
        return "CURRENT_USER_ID"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basic screen setup
        title = "My Donations"
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()  // removes empty cell separators
        
        // Load donations when the screen first appears
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure nav bar is visible when this screen is shown
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Reload in case new donations were added
        reloadData()
    }
    
    // Calls DonationService to get all donations for this donor
    private func reloadData() {
        DonationService.shared.fetchForDonor(donorId: currentDonorId) { [weak self] items in
            DispatchQueue.main.async {
                self?.donations = items
                self?.tableView.reloadData()
                self?.updateEmptyState()
            }
        }
    }
    
    // Shows a friendly message when the list is empty
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
        return 1   // simple list, only one section
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
        
        // Main title: quantity + item name
        cell.textLabel?.text = "\(donation.quantity)x \(donation.title)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        // Expiry date if we have one, otherwise "-"
        let dateString: String
        if let exp = donation.expiryDate {
            dateString = dateFormatter.string(from: exp)
        } else {
            dateString = "-"
        }
        
        // Show NGO and expiry date in the subtitle
        let ngoName = donation.ngoId ?? "Unknown NGO"
        cell.detailTextLabel?.text = "To: \(ngoName) • Exp: \(dateString)"
        cell.detailTextLabel?.textColor = UIColor(white: 0.45, alpha: 1.0)
        cell.detailTextLabel?.numberOfLines = 2
        
        // If there are notes/description, show a arrow to hint that row is tappable
        cell.accessoryType = donation.description.isEmpty ? .none : .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate (tap to see notes/description)
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let donation = donations[indexPath.row]
        guard !donation.description.isEmpty else { return }
        
        // Show the notes in a simple alert when the user taps a row
        let alert = UIAlertController(
            title: "Notes",
            message: donation.description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
