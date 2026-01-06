//
//  OrganizationDiscoveryViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

class OrganizationDiscoveryViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var filterStackView: UIStackView!
    @IBOutlet weak var searchNGOsButton: UIButton!
    @IBOutlet weak var verifiedButton: UIButton!

    // MARK: - Firebase
    private let db = Firestore.firestore()

    // MARK: - Data
    private var allNgos: [DiscoveryNGO] = []
    private var filteredNgos: [DiscoveryNGO] = []
    private var isShowingVerifiedOnly = false
    private var isSearchActive = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Organization Discovery"
        configureNavigationBar()

        collectionView.dataSource = self
        collectionView.delegate = self

        searchBar.delegate = self
        searchBar.isHidden = true
        searchBar.showsCancelButton = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        updateButtonStyles()
        fetchNGOs()
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

    // MARK: - Firestore
    private func fetchNGOs() {
        db.collection("ngos_reviews").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Firestore NGOs error:", error)
                return
            }

            let docs = snapshot?.documents ?? []
            self?.allNgos = docs.compactMap { DiscoveryNGO(doc: $0) }
            self?.applyFilters()
        }
    }

    // MARK: - Actions
    @IBAction func searchNGOsTapped(_ sender: UIButton) {
        isSearchActive.toggle()

        UIView.animate(withDuration: 0.3) {
            self.searchBar.isHidden = !self.isSearchActive
            self.filterStackView.isHidden = self.isSearchActive
        }

        if isSearchActive {
            searchBar.becomeFirstResponder()
        } else {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            applyFilters()
        }

        updateButtonStyles()
    }

    @IBAction func verifiedTapped(_ sender: UIButton) {
        isShowingVerifiedOnly.toggle()
        applyFilters()
        updateButtonStyles()
    }

    // MARK: - Filtering
    private func applyFilters() {
        var results = allNgos

        if isShowingVerifiedOnly {
            results = results.filter { $0.verified }
        }

        let query = (searchBar.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if !query.isEmpty {
            results = results.filter {
                $0.name.lowercased().contains(query) ||
                $0.desc.lowercased().contains(query)
            }
        }

        filteredNgos = results
        collectionView.reloadData()
    }

    // MARK: - Button Styles
    private func updateButtonStyles() {
        if isSearchActive {
            searchNGOsButton.backgroundColor = .systemBlue
            searchNGOsButton.setTitleColor(.white, for: .normal)
        } else {
            searchNGOsButton.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.94, alpha: 1.0)
            searchNGOsButton.setTitleColor(.systemBlue, for: .normal)
        }

        if isShowingVerifiedOnly {
            verifiedButton.backgroundColor = .systemBlue
            verifiedButton.setTitleColor(.white, for: .normal)
        } else {
            verifiedButton.backgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.94, alpha: 1.0)
            verifiedButton.setTitleColor(.systemBlue, for: .normal)
        }
    }

    // MARK: - Navigation to Details
    private func openDetails(for ngo: DiscoveryNGO) {
        let storyboard = UIStoryboard(name: "NgoOrginzationDiscovery", bundle: nil)

        guard let detailsVC = storyboard.instantiateViewController(withIdentifier: "NGODetailsViewController") as? NGODetailsViewController else {
            print("Could not find NGODetailsViewController")
            return
        }

        detailsVC.ngoId = ngo.id
        detailsVC.ngoName = ngo.name
        detailsVC.ngoDescription = ngo.fullDescription
        detailsVC.ngoImageName = ngo.imageName
        detailsVC.ngoRating = ngo.rating
        detailsVC.ngoReviews = ngo.reviews
        detailsVC.ngoPhone = ngo.phone
        detailsVC.ngoEmail = ngo.email
        detailsVC.ngoAddress = ngo.address
        detailsVC.isVerified = ngo.verified

        navigationController?.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension OrganizationDiscoveryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredNgos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NGOCardCell",
                                                      for: indexPath) as! NGOCardCell

        let ngo = filteredNgos[indexPath.item]
        cell.nameLabel.text = ngo.name
        cell.descriptionLabel.text = ngo.desc
        cell.verifiedBadgeView.isHidden = !ngo.verified
        cell.delegate = self

        if let image = UIImage(named: ngo.imageName) {
            cell.logoImageView.image = image
            cell.logoImageView.tintColor = nil
        } else {
            cell.logoImageView.image = UIImage(systemName: "building.2.fill")
            cell.logoImageView.tintColor = .gray
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OrganizationDiscoveryViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ngo = filteredNgos[indexPath.item]
        openDetails(for: ngo)
    }
}

// MARK: - NGOCardCellDelegate
extension OrganizationDiscoveryViewController: NGOCardCellDelegate {

    func didTapLearnMore(at cell: NGOCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let ngo = filteredNgos[indexPath.item]
        openDetails(for: ngo)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OrganizationDiscoveryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let spacing: CGFloat = 16
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: 280)
    }
}

// MARK: - UISearchBarDelegate
extension OrganizationDiscoveryViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applyFilters()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isSearchActive = false

        UIView.animate(withDuration: 0.3) {
            self.searchBar.isHidden = true
            self.filterStackView.isHidden = false
        }

        searchBar.resignFirstResponder()
        applyFilters()
        updateButtonStyles()
    }
}

