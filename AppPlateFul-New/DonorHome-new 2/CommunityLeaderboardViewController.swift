//
//  CommunityLeaderboardViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

// MARK: - Data Models
struct LeaderboardDonor {
    let id: String
    let name: String
    let avatarImage: UIImage?
    let donationCount: Int
    var isFavorite: Bool
}

struct LeaderboardNGO {
    let id: String
    let name: String
    let logoImage: UIImage?
    let mealsCount: Int
    var isFavorite: Bool
}

// MARK: - Filter Type
enum LeaderboardFilter {
    case all, thisWeek, thisMonth, thisYear
}

// MARK: - Leaderboard Cell
class LeaderboardCell: UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var rankBadge: UIView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var statsContainer: UIView!
    @IBOutlet weak var statsNumberLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    private let goldColor = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
    private let silverColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    private let bronzeColor = UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
    private let primaryGreen = UIColor(red: 0.256, green: 0.573, blue: 0.166, alpha: 1.0)
    private let accentTan = UIColor(red: 0.776, green: 0.635, blue: 0.494, alpha: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true
        selectionStyle = .none
    }
    
    func configure(rank: Int, name: String, subtitle: String, statsNumber: String, statsText: String, image: UIImage?, isDonor: Bool) {
        rankLabel.text = "\(rank)"
        nameLabel.text = name
        subtitleLabel.text = subtitle
        statsNumberLabel.text = statsNumber
        statsLabel.text = statsText
        
        switch rank {
        case 1:
            rankBadge.backgroundColor = goldColor
            rankLabel.textColor = .black
        case 2:
            rankBadge.backgroundColor = silverColor
            rankLabel.textColor = .black
        case 3:
            rankBadge.backgroundColor = bronzeColor
            rankLabel.textColor = .white
        default:
            rankBadge.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            rankLabel.textColor = UIColor(white: 0.4, alpha: 1.0)
        }
        
        if let image = image {
            avatarImageView.image = image
            avatarImageView.contentMode = .scaleAspectFill
        } else {
            avatarImageView.image = UIImage(systemName: isDonor ? "person.circle.fill" : "building.2.fill")
            avatarImageView.tintColor = isDonor ? accentTan : primaryGreen
            avatarImageView.contentMode = .scaleAspectFit
        }
        
        statsContainer.backgroundColor = (isDonor ? accentTan.withAlphaComponent(0.15) : primaryGreen.withAlphaComponent(0.1))
        statsNumberLabel.textColor = isDonor ? accentTan : primaryGreen
    }
}

// MARK: - Community Leaderboard
class CommunityLeaderboardViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var filterAllButton: UIButton!
    @IBOutlet weak var filterWeekButton: UIButton!
    @IBOutlet weak var filterMonthButton: UIButton!
    @IBOutlet weak var filterYearButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    
    // MARK: - Properties
    private var allDonations: [Donation] = []
    private var allDonors: [LeaderboardDonor] = []
    private var allNGOs: [LeaderboardNGO] = []
    private var filteredDonors: [LeaderboardDonor] = []
    private var filteredNGOs: [LeaderboardNGO] = []
    private var currentFilter: LeaderboardFilter = .all
    private var searchText: String = ""
    private var isLoading = false
    private var ngoNameCache: [String: String] = [:]
    
    private let primaryGreen = UIColor(red: 0.256, green: 0.573, blue: 0.166, alpha: 1.0)
    private let accentTan = UIColor(red: 0.776, green: 0.635, blue: 0.494, alpha: 1.0)
    
    private var isShowingDonors: Bool { segmentedControl.selectedSegmentIndex == 0 }
    
    private var filterButtons: [UIButton] { [filterAllButton, filterWeekButton, filterMonthButton, filterYearButton] }
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = primaryGreen
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActivityIndicator()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    private func setupUI() {
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        emptyStateView.isHidden = true
        updateFilterButtons()
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Load All Donations
    private func loadData() {
        guard !isLoading else { return }
        isLoading = true
        
        activityIndicator.startAnimating()
        tableView.isHidden = true
        emptyStateView.isHidden = true
        
        // Fetch all donations from Firebase
        DonationService.shared.fetchAll { [weak self] donations in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                self.activityIndicator.stopAnimating()
                
                self.allDonations = donations
                self.processLeaderboardData()
            }
        }
    }
    
    private func processLeaderboardData() {
        let filteredByTime = filterDonationsByTime(allDonations)
        let completedDonations = filteredByTime.filter { $0.status == .completed }
        
        var donorStats: [String: (name: String, count: Int)] = [:]
        var ngoStats: [String: (name: String, mealsCount: Int)] = [:]
        
        for donation in completedDonations {
            let donorId = donation.donorId
            let donorName = donation.donorName.isEmpty ? "Anonymous Donor" : donation.donorName
            donorStats[donorId] = (donorName, (donorStats[donorId]?.count ?? 0) + 1)
            
            if let ngoId = donation.ngoId, !ngoId.isEmpty {
                let quantity = parseQuantity(donation.quantity)
                let ngoName = ngoNameCache[ngoId] ?? "NGO Organization"
                ngoStats[ngoId] = (ngoName, (ngoStats[ngoId]?.mealsCount ?? 0) + quantity)
            }
        }
        
        allDonors = donorStats.map { LeaderboardDonor(id: $0.key, name: $0.value.name, avatarImage: nil, donationCount: $0.value.count, isFavorite: false) }
            .sorted { $0.donationCount > $1.donationCount }
        
        allNGOs = ngoStats.map { LeaderboardNGO(id: $0.key, name: $0.value.name, logoImage: nil, mealsCount: $0.value.mealsCount, isFavorite: false) }
            .sorted { $0.mealsCount > $1.mealsCount }
        
        fetchNGONames()
        applyFilters()
    }
    
    private func filterDonationsByTime(_ donations: [Donation]) -> [Donation] {
        let calendar = Calendar.current
        let now = Date()
        
        switch currentFilter {
        case .all: return donations
        case .thisWeek:
            guard let weekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: now) else { return donations }
            return donations.filter { getDonationDate($0) >= weekAgo }
        case .thisMonth:
            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else { return donations }
            return donations.filter { getDonationDate($0) >= monthAgo }
        case .thisYear:
            guard let yearAgo = calendar.date(byAdding: .year, value: -1, to: now) else { return donations }
            return donations.filter { getDonationDate($0) >= yearAgo }
        }
    }
    
    private func getDonationDate(_ donation: Donation) -> Date {
        donation.scheduledPickup?.pickupDate ?? donation.expiryDate ?? Date()
    }
    
    private func parseQuantity(_ quantityString: String) -> Int {
        let numbers = quantityString.components(separatedBy: CharacterSet.decimalDigits.inverted)
        let numericString = numbers.joined()
        return Int(numericString) ?? 1
    }
    
    private func fetchNGONames() {
        let db = Firestore.firestore()
        let ngoIds = allNGOs.map { $0.id }.filter { !ngoNameCache.keys.contains($0) }
        
        guard !ngoIds.isEmpty else { return }
        
        for ngoId in ngoIds {
            db.collection("users").document(ngoId).getDocument { [weak self] snapshot, _ in
                guard let self = self, let data = snapshot?.data() else { return }
                let name = data["name"] as? String ?? data["organizationName"] as? String ?? "NGO"
                self.ngoNameCache[ngoId] = name
                
                if let index = self.allNGOs.firstIndex(where: { $0.id == ngoId }) {
                    let ngo = self.allNGOs[index]
                    self.allNGOs[index] = LeaderboardNGO(id: ngo.id, name: name, logoImage: ngo.logoImage, mealsCount: ngo.mealsCount, isFavorite: ngo.isFavorite)
                    self.applyFilters()
                }
            }
        }
    }
    
    private func applyFilters() {
        filteredDonors = searchText.isEmpty ? allDonors : allDonors.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        filteredNGOs = searchText.isEmpty ? allNGOs : allNGOs.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        updateEmptyState()
        tableView.reloadData()
    }
    
    private func updateEmptyState() {
        let isEmpty = isShowingDonors ? filteredDonors.isEmpty : filteredNGOs.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func updateFilterButtons() {
        let filters: [LeaderboardFilter] = [.all, .thisWeek, .thisMonth, .thisYear]
        for (index, button) in filterButtons.enumerated() {
            let isSelected = filters[index] == currentFilter
            button.backgroundColor = isSelected ? primaryGreen : .white
            button.configuration?.baseForegroundColor = isSelected ? .white : UIColor(white: 0.4, alpha: 1.0)
            button.layer.borderWidth = isSelected ? 0 : 1
            button.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).cgColor
        }
    }
    
    private func formatNumber(_ number: Int) -> String {
        number >= 1000 ? String(format: "%.1fK", Double(number)/1000.0) : "\(number)"
    }
    
    private func refreshData() { processLeaderboardData() }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let nav = navigationController { nav.popViewController(animated: true) }
        else if presentingViewController != nil { dismiss(animated: true) }
    }
    
    @IBAction func filterAllTapped(_ sender: UIButton) { currentFilter = .all; updateFilterButtons(); refreshData() }
    @IBAction func filterWeekTapped(_ sender: UIButton) { currentFilter = .thisWeek; updateFilterButtons(); refreshData() }
    @IBAction func filterMonthTapped(_ sender: UIButton) { currentFilter = .thisMonth; updateFilterButtons(); refreshData() }
    @IBAction func filterYearTapped(_ sender: UIButton) { currentFilter = .thisYear; updateFilterButtons(); refreshData() }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) { applyFilters() }
    @objc private func searchTextChanged() { searchText = searchField.text ?? ""; applyFilters() }
}

// MARK: - UITableViewDataSource
extension CommunityLeaderboardViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isShowingDonors ? filteredDonors.count : filteredNGOs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath) as? LeaderboardCell else { return UITableViewCell() }
        
        let rank = indexPath.row + 1
        
        if isShowingDonors {
            let donor = filteredDonors[indexPath.row]
            cell.configure(rank: rank, name: donor.name, subtitle: "\(donor.donationCount) donations made",
                           statsNumber: formatNumber(donor.donationCount), statsText: "donations",
                           image: donor.avatarImage, isDonor: true)
        } else {
            let ngo = filteredNGOs[indexPath.row]
            cell.configure(rank: rank, name: ngo.name, subtitle: "\(formatNumber(ngo.mealsCount)) meals distributed",
                           statsNumber: formatNumber(ngo.mealsCount), statsText: "meals",
                           image: ngo.logoImage, isDonor: false)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CommunityLeaderboardViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? LeaderboardCell {
            UIView.animate(withDuration: 0.1, animations: { cell.cardView.transform = CGAffineTransform(scaleX: 0.98, y: 0.98) }) { _ in
                UIView.animate(withDuration: 0.1) { cell.cardView.transform = .identity }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }
}

// MARK: - UITextFieldDelegate
extension CommunityLeaderboardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

