//
//  OrganizationDiscoveryViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

final class OrganizationDiscoveryViewController: UIViewController {

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

    // MARK: - Layout
    private let gridInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    private let gridSpacing: CGFloat = 16
    private let gridColumns: CGFloat = 2

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Organization Discovery"
        configureNavigationBar()

        // Top spacing fix , prevents nav bar being pushed down
        navigationController?.navigationBar.isTranslucent = true
        edgesForExtendedLayout = [.top]
        extendedLayoutIncludesOpaqueBars = true

        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }

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


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never

        title = "Organization Discovery"
    }

    
    func addFavorite(ngoId: String) {
        guard let userId = UserSession.shared.userId else {
            print("addFavorite failed: no logged-in user")
            return
        }

        db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(ngoId)
            .setData([
                "ngoId": ngoId,
                "createdAt": FieldValue.serverTimestamp()
            ])
    }

    
    
    func removeFavorite(ngoId: String) {
        guard let userId = UserSession.shared.userId else {
            print("removeFavorite failed: no logged-in user")
            return
        }

        db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(ngoId)
            .delete()
    }



    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }




    // MARK: - Arrow-only Back Button
    private func setupCustomNavBackButton() {
        let backImage = UIImage(
            systemName: "chevron.left",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium)
        )

        let backButton = UIBarButtonItem(
            image: backImage,
            style: .plain,
            target: self,
            action: #selector(customBackTapped)
        )

        navigationItem.leftBarButtonItem = backButton
    }

    // If you still have a storyboard back UIButton connected, this reuses same logic
    @IBAction func backTapped(_ sender: Any) {
        customBackTapped()
    }

    @objc private func customBackTapped() {
        // 1) Pushed in a nav stack
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
            return
        }

        // 2) Presented modally
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }

        // 3) Root / broken navigation -> force donor home
        goToDonorHomeHardReset()
    }

    // MARK: - Hard reset to Donor Home
    private func goToDonorHomeHardReset() {
        // Change these ONLY if your DonorHome has a different storyboard/id
        let storyboardNames = ["Main", "DonorDashboard"]
        let identifiers = ["DonorHomeViewController", "DonorHomeVC"]

        for sbName in storyboardNames {
            let sb = UIStoryboard(name: sbName, bundle: nil)

            for id in identifiers {
                let vc = sb.instantiateViewController(withIdentifier: id)

                // If we already have nav, replace stack
                if let nav = navigationController {
                    nav.setViewControllers([vc], animated: true)
                    return
                }

                // No nav: create one and replace root
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen

                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first {
                    window.rootViewController = nav
                    window.makeKeyAndVisible()
                    return
                }

                // fallback
                present(nav, animated: true)
                return
            }
        }

        // last fallback
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }

    // MARK: - Nav Bar
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

    // MARK: - Firestore
    private func fetchNGOs() {
        db.collection("ngo_reviews")
            .getDocuments { [weak self] snap, error in
                guard let self else { return }

                if let error = error {
                    print("Firestore error:", error.localizedDescription)
                    return
                }

                let results: [DiscoveryNGO] = snap?.documents.compactMap { DiscoveryNGO(doc: $0) } ?? []
                self.allNgos = results

                DispatchQueue.main.async {
                    self.applyFilters()
                }
            }
    }

    // MARK: - Actions
    @IBAction func searchNGOsTapped(_ sender: UIButton) {
        isSearchActive.toggle()

        UIView.animate(withDuration: 0.25) {
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

    // MARK: - Image config (prevents zoom)
    private func configureLogoView(_ imageView: UIImageView) {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        imageView.tintColor = nil
    }
}

// MARK: - UICollectionViewDataSource
extension OrganizationDiscoveryViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredNgos.count
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

        configureLogoView(cell.logoImageView)

        let placeholder = UIImage(systemName: "building.2.fill")
        let imgValue = ngo.imageName.trimmingCharacters(in: .whitespacesAndNewlines)

        if imgValue.lowercased().hasPrefix("http") {
            ImageLoader.shared.load(imgValue, into: cell.logoImageView, placeholder: placeholder)
        } else {
            if let img = UIImage(named: imgValue) {
                cell.logoImageView.image = img
            } else {
                cell.logoImageView.image = placeholder
                cell.logoImageView.tintColor = .gray
            }
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension OrganizationDiscoveryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openDetails(for: filteredNgos[indexPath.item])
    }
}

// MARK: - NGOCardCellDelegate
extension OrganizationDiscoveryViewController: NGOCardCellDelegate {
    func didTapLearnMore(at cell: NGOCardCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        openDetails(for: filteredNgos[indexPath.item])
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension OrganizationDiscoveryViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        gridInsets
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        gridSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        gridSpacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalHorizontal = gridInsets.left + gridInsets.right + gridSpacing * (gridColumns - 1)
        let width = floor((collectionView.bounds.width - totalHorizontal) / gridColumns)
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

        UIView.animate(withDuration: 0.25) {
            self.searchBar.isHidden = true
            self.filterStackView.isHidden = false
        }

        searchBar.resignFirstResponder()
        applyFilters()
        updateButtonStyles()
    }
}
