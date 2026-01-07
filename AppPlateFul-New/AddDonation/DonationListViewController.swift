import UIKit

class DonationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var donations: [Donation] = []
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy – h:mm a"
        return f
    }()
    
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
        donations = DonationStore.shared.load()
        tableView.reloadData()
        updateEmptyState()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return donations.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseId = "DonationCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseId)
        
        let donation = donations[indexPath.row]
        
        cell.textLabel?.text = "\(donation.quantity)x \(donation.itemName)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        let dateString = dateFormatter.string(from: donation.date)
        cell.detailTextLabel?.text = "To: \(donation.donatedTo) • \(dateString)"
        cell.detailTextLabel?.textColor = UIColor(white: 0.45, alpha: 1.0)
        cell.detailTextLabel?.numberOfLines = 2
        
        // Show arrow if there are notes
        cell.accessoryType = donation.specialNotes.isEmpty ? .none : .disclosureIndicator
        
        return cell
    }
    
    // MARK: - UITableViewDelegate (tap to see notes)
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let donation = donations[indexPath.row]
        guard !donation.specialNotes.isEmpty else { return }
        
        let alert = UIAlertController(
            title: "Notes",
            message: donation.specialNotes,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
