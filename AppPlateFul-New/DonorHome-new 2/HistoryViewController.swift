import UIKit
import FirebaseStorage

class HistoryViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    private let searchBar = UISearchBar()
    
    // Time filter buttons
    private let filterStack = UIStackView()
    private let allButton = UIButton(type: .system)
    private let weekButton = UIButton(type: .system)
    private let monthButton = UIButton(type: .system)
    private let yearButton = UIButton(type: .system)

    // MARK: - Data
    var histories: [Donation] = []
    var filteredHistories: [Donation] = []
    var selectedHistory: Donation?

    // Cache downloaded images
    private var imageCache: [String: UIImage] = [:]

    // Current filter
    enum TimeFilter { case all, thisWeek, thisMonth, thisYear }
    private var currentTimeFilter: TimeFilter = .all

    // Colors
    private let primaryGreen = UIColor(red: 173/255, green: 193/255, blue: 148/255, alpha: 1.0) // #adc194

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableHeader()
        setupTableView()
        fetchDonationsForCurrentUser()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let headerView = tableView.tableHeaderView {
            let size = headerView.systemLayoutSizeFitting(CGSize(width: tableView.frame.width, height: 0))
            if headerView.frame.height != size.height {
                headerView.frame.size.height = size.height
                tableView.tableHeaderView = headerView
            }
        }
    }
    

    @objc private func dismissKeyboard() { searchBar.resignFirstResponder() }

    // MARK: - Setup Table Header
    private func setupTableHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false

        searchBar.placeholder = "Search donations..."
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(searchBar)

        filterStack.axis = .horizontal
        filterStack.distribution = .fillEqually
        filterStack.spacing = 8
        filterStack.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(filterStack)

        allButton.setTitle("All", for: .normal)
        weekButton.setTitle("This Week", for: .normal)
        monthButton.setTitle("This Month", for: .normal)
        yearButton.setTitle("This Year", for: .normal)

        [allButton, weekButton, monthButton, yearButton].forEach { button in
            button.layer.cornerRadius = 8
            button.layer.borderWidth = 1
            button.layer.borderColor = primaryGreen.cgColor
            button.backgroundColor = .white
            button.setTitleColor(primaryGreen, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            filterStack.addArrangedSubview(button)
        }
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()

        updateFilterButtonColors()

        let horizontalPadding: CGFloat = 24
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: horizontalPadding),
            searchBar.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -horizontalPadding),
            searchBar.heightAnchor.constraint(equalToConstant: 40),

            filterStack.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            filterStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: horizontalPadding),
            filterStack.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -horizontalPadding),
            filterStack.heightAnchor.constraint(equalToConstant: 36),
            filterStack.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])

        tableView.tableHeaderView = headerView
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.keyboardDismissMode = .onDrag
    }

    // MARK: - Fetch Donations
    private func fetchDonationsForCurrentUser() {
        guard let userId = UserSession.shared.userId else { return }

        DonationService.shared.fetchForDonor(donorId: userId) { [weak self] donations in
            guard let self = self else { return }
            self.histories = donations.filter { $0.status == .completed || $0.status == .cancelled }
            self.histories.sort { ($0.expiryDate ?? Date.distantPast) > ($1.expiryDate ?? Date.distantPast) }

            // Preload images
            self.preloadDonationImages(donations: self.histories)

            self.applyFilters()
        }
    }

    // MARK: - Preload images from Firebase
    private func preloadDonationImages(donations: [Donation]) {
        for donation in donations {
            guard imageCache[donation.imageRef] == nil else { continue } // Already cached
            let storageRef = Storage.storage().reference(withPath: donation.imageRef)
            storageRef.downloadURL { [weak self] url, error in
                guard let self = self, let url = url, error == nil else { return }
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    guard let data = data, let image = UIImage(data: data) else { return }
                    self.imageCache[donation.imageRef] = image
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }.resume()
            }
        }
    }

    // MARK: - Filters (by expiryDate)
    private func getExpiryDate(_ donation: Donation) -> Date {
        return donation.expiryDate ?? Date.distantPast
    }

    private func filterHistoriesByTime(_ donations: [Donation], filter: TimeFilter) -> [Donation] {
        let calendar = Calendar.current
        let now = Date()
        switch filter {
        case .all:
            return donations
        case .thisWeek:
            guard let weekFromNow = calendar.date(byAdding: .day, value: 7, to: now) else { return donations }
            return donations.filter {
                let expiry = getExpiryDate($0)
                return expiry >= now && expiry <= weekFromNow
            }
        case .thisMonth:
            guard let monthFromNow = calendar.date(byAdding: .month, value: 1, to: now) else { return donations }
            return donations.filter {
                let expiry = getExpiryDate($0)
                return expiry >= now && expiry <= monthFromNow
            }
        case .thisYear:
            guard let yearFromNow = calendar.date(byAdding: .year, value: 1, to: now) else { return donations }
            return donations.filter {
                let expiry = getExpiryDate($0)
                return expiry >= now && expiry <= yearFromNow
            }
        }
    }

    private func applyFilters() {
        var temp = filterHistoriesByTime(histories, filter: currentTimeFilter)
        if let text = searchBar.text, !text.isEmpty {
            let lower = text.lowercased()
            temp = temp.filter { $0.title.lowercased().contains(lower) || $0.description.lowercased().contains(lower) }
        }
        filteredHistories = temp
        tableView.reloadData()
    }

    @objc private func filterButtonTapped(_ sender: UIButton) {
        switch sender {
        case allButton: currentTimeFilter = .all
        case weekButton: currentTimeFilter = .thisWeek
        case monthButton: currentTimeFilter = .thisMonth
        case yearButton: currentTimeFilter = .thisYear
        default: break
        }
        updateFilterButtonColors()
        applyFilters()
    }

    private func updateFilterButtonColors() {
        let buttons: [(UIButton, TimeFilter)] = [
            (allButton, .all),
            (weekButton, .thisWeek),
            (monthButton, .thisMonth),
            (yearButton, .thisYear)
        ]
        for (button, filter) in buttons {
            if filter == currentTimeFilter {
                button.backgroundColor = primaryGreen
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .white
                button.setTitleColor(primaryGreen, for: .normal)
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToHistoryDetails",
           let detailsVC = segue.destination as? HistoryDetailsViewController {
            detailsVC.donation = selectedHistory
        }
    }
}

// MARK: - TableView
extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredHistories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryCell",
            for: indexPath
        ) as! HistoryTableViewCell

        let donation = filteredHistories[indexPath.row]
        cell.configure(with: donation)

        // Pass cached image if available
        if let image = imageCache[donation.imageRef] {
            cell.historyImageView.image = image
        } else {
            cell.historyImageView.image = UIImage(systemName: "photo")
        }

        cell.onDetailsTapped = { [weak self] in
            self?.selectedHistory = donation
            self?.performSegue(withIdentifier: "goToHistoryDetails", sender: nil)
        }

        return cell
    }
}

// MARK: - Search
extension HistoryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { applyFilters() }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { searchBar.resignFirstResponder() }
}
