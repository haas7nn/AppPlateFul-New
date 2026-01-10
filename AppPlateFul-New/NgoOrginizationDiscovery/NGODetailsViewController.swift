//
//  NGODetailsViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

final class NGODetailsViewController: UIViewController {

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
    private var userId: String {
        guard let id = UserSession.shared.userId else {
            fatalError(" User not logged in but userId accessed")
        }
        return id
    }

    // MARK: - NGO Data (set before push)
    var ngoId: String = ""
    var ngoName: String = ""
    var ngoDescription: String = ""
    var ngoImageName: String = ""
    var ngoRating: Double = 0.0
    var ngoReviews: Int = 0
    var ngoPhone: String = ""
    var ngoEmail: String = ""
    var ngoAddress: String = ""
    var isVerified: Bool = false

    // MARK: - State
    private var isFavorite: Bool = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Details"
        configureNavigationBar()
        configureUI()
        checkIfFavorite()
    }

    // Hide tab bar ONLY on this screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    // Bring tab bar back when leaving this screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

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
        nameLabel.text = ngoName
        ratingLabel.text = "\(ngoRating) (\(ngoReviews))"
        descriptionLabel.text = ngoDescription
        phoneInfoLabel.text = "Contact us: \(ngoPhone)"
        emailLabel.text = "Email: \(ngoEmail)"
        addressLabel.text = "Address: \(ngoAddress)"
        verifiedBadgeView.isHidden = !isVerified

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        let green = UIColor(red: 0.73, green: 0.80, blue: 0.63, alpha: 1.0)
        addToFavoritesButton.backgroundColor = green
        addToFavoritesButton.layer.cornerRadius = 12
        addToFavoritesButton.clipsToBounds = true

        reviewsButton.backgroundColor = green
        reviewsButton.layer.cornerRadius = 12
        reviewsButton.clipsToBounds = true

        loadNGOImage()
        updateFavoriteButton()
    }

    private func loadNGOImage() {
        let placeholder = UIImage(systemName: "photo")
        let trimmed = ngoImageName.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.lowercased().hasPrefix("http"),
           let url = URL(string: trimmed) {

            imageView.image = placeholder

            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self else { return }
                guard let data = data, let img = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self.imageView.image = img
                }
            }.resume()

        } else {
            imageView.image = UIImage(named: trimmed) ?? placeholder
        }
    }

    // MARK: - Favorites (same path as Favorites page)
    private func favDocRef() -> DocumentReference {
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(ngoId)
    }

    private func checkIfFavorite() {
        guard ngoId.isEmpty == false else {
            print("ngoId is empty. Not passed from discovery.")
            return
        }

        favDocRef().getDocument { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                print("checkIfFavorite:", error.localizedDescription)
                return
            }

            self.isFavorite = snap?.exists ?? false
            self.updateFavoriteButton()
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

    private func addFavorite(completion: @escaping () -> Void) {
        guard ngoId.isEmpty == false else { return }

        favDocRef().setData([
            "createdAt": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("addFavorite:", error.localizedDescription)
            }
            completion()
        }
    }

    private func removeFavorite(completion: @escaping () -> Void) {
        guard ngoId.isEmpty == false else { return }

        favDocRef().delete { error in
            if let error = error {
                print("removeFavorite:", error.localizedDescription)
            }
            completion()
        }
    }

    // MARK: - Actions
    @IBAction func addToFavoritesTapped(_ sender: UIButton) {
        if ngoId.isEmpty { return }

        if isFavorite {
            let alert = UIAlertController(
                title: "Remove Favorite",
                message: "Are you sure you want to remove this from favorites?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive) { _ in
                self.removeFavorite {
                    self.isFavorite = false
                    self.updateFavoriteButton()
                    self.showFavoriteAlert(message: "Removed from Favorites")
                }
            })
            present(alert, animated: true)
        } else {
            addFavorite {
                self.isFavorite = true
                self.updateFavoriteButton()
                self.showFavoriteAlert(message: "Added to Favorites")
            }
        }
    }

    @IBAction func reviewsTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "NgoOrginzationDiscovery", bundle: nil)
        if let reviewsVC = storyboard.instantiateViewController(withIdentifier: "NGOReviewsViewController") as? NGOReviewsViewController {

            reviewsVC.ngoId = ngoId
            reviewsVC.ngoName = ngoName
            reviewsVC.ngoImageName = ngoImageName
            reviewsVC.ngoRating = ngoRating
            reviewsVC.ngoReviews = ngoReviews
            reviewsVC.isVerified = isVerified
            reviewsVC.ngoAddress = ngoAddress

            navigationController?.pushViewController(reviewsVC, animated: true)
        }
    }

    @IBAction func phoneTapped(_ sender: UIButton) {
        let number = ngoPhone.trimmingCharacters(in: .whitespacesAndNewlines)

        let alert = UIAlertController(
            title: "Call NGO",
            message: number.isEmpty ? "No phone number available." : number,
            preferredStyle: .actionSheet
        )

        if !number.isEmpty {
            alert.addAction(UIAlertAction(title: "Call", style: .default) { _ in
                let digits = number.filter { "0123456789+".contains($0) }
                if let url = URL(string: "tel://\(digits)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentActionSheet(alert, from: sender)
    }

    @IBAction func messageTapped(_ sender: UIButton) {
        let number = ngoPhone.trimmingCharacters(in: .whitespacesAndNewlines)

        let alert = UIAlertController(
            title: "Message NGO",
            message: number.isEmpty ? "No number available for messaging." : number,
            preferredStyle: .actionSheet
        )

        if !number.isEmpty {
            alert.addAction(UIAlertAction(title: "Message", style: .default) { _ in
                let digits = number.filter { "0123456789+".contains($0) }
                if let url = URL(string: "sms:\(digits)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        presentActionSheet(alert, from: sender)
    }

    private func showFavoriteAlert(message: String) {
        let alert = UIAlertController(title: "Favorites", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func presentActionSheet(_ alert: UIAlertController, from source: UIView) {
        if let pop = alert.popoverPresentationController {
            pop.sourceView = source
            pop.sourceRect = source.bounds
        }
        present(alert, animated: true)
    }
}
