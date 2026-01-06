//
//  NGODetailsViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

class NGODetailsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var phoneInfoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var verifiedBadgeView: UIView!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var reviewsButton: UIButton!

    // MARK: - Firebase
    private let db = Firestore.firestore()
    private let userId = UIDevice.current.identifierForVendor?.uuidString ?? "guest"

    // MARK: - NGO Data
    var ngoId: String = ""          // 🔥 REQUIRED
    var ngoName: String = ""
    var ngoDescription: String = ""
    var ngoImageName: String = ""
    var ngoRating: Double = 0.0
    var ngoReviews: Int = 0
    var ngoPhone: String = ""
    var ngoEmail: String = ""
    var ngoAddress: String = ""
    var isVerified: Bool = false

    // MARK: - Favorites State
    private var isFavorite: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Details"
        configureNavigationBar()
        configureUI()
        checkIfFavorite()
    }

    // MARK: - UI
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.98, green: 0.96, blue: 0.94, alpha: 1.0)
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

    private func configureUI() {
        imageView.image = UIImage(named: ngoImageName) ?? UIImage(systemName: "photo")
        nameLabel.text = ngoName
        ratingLabel.text = "\(ngoRating) (\(ngoReviews))"
        descriptionLabel.text = ngoDescription
        phoneInfoLabel.text = "Contact us: \(ngoPhone)"
        emailLabel.text = "Email: \(ngoEmail)"
        addressLabel.text = "Address: \(ngoAddress)"
        verifiedBadgeView.isHidden = !isVerified

        let green = UIColor(red: 0.73, green: 0.80, blue: 0.63, alpha: 1.0)
        addToFavoritesButton.backgroundColor = green
        addToFavoritesButton.layer.cornerRadius = 12
        reviewsButton.backgroundColor = green
        reviewsButton.layer.cornerRadius = 12
    }

    // MARK: - Favorites (Firestore)
    private func checkIfFavorite() {
        guard !ngoId.isEmpty else { return }

        db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(ngoId)
            .getDocument { [weak self] snap, _ in
                self?.isFavorite = snap?.exists ?? false
                self?.updateFavoriteButton()
            }
    }

    private func updateFavoriteButton() {
        if isFavorite {
            addToFavoritesButton.setTitle("Remove from Favorites", for: .normal)
            addToFavoritesButton.setTitleColor(.systemRed, for: .normal)
        } else {
            addToFavoritesButton.setTitle("Add to Favorites", for: .normal)
            addToFavoritesButton.setTitleColor(.white, for: .normal)
        }
    }

    private func addFavorite() {
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(ngoId)
            .setData([
                "name": ngoName,
                "imageName": ngoImageName,
                "rating": ngoRating
            ])
    }

    private func removeFavorite() {
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(ngoId)
            .delete()
    }

    // MARK: - Actions
    @IBAction func addToFavoritesTapped(_ sender: UIButton) {
        if isFavorite {
            removeFavorite()
            isFavorite = false
        } else {
            addFavorite()
            isFavorite = true
        }
        updateFavoriteButton()
    }

    @IBAction func reviewsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NgoOrginzationDiscovery", bundle: nil)
        if let reviewsVC = storyboard.instantiateViewController(withIdentifier: "NGOReviewsViewController") as? NGOReviewsViewController {
            reviewsVC.ngoId = ngoId
            reviewsVC.ngoName = ngoName
            navigationController?.pushViewController(reviewsVC, animated: true)
        }
    }
}
