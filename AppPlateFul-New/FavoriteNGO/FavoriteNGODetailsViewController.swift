import UIKit
import FirebaseFirestore

final class FavoriteNGODetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var phoneInfoLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!

    var ngo: FavoriteNGO!

    private let db = Firestore.firestore()
    private var userId: String {
        guard let id = UserSession.shared.userId else {
            fatalError("userId accessed but no user is logged in")
        }
        return id
    }
    private var imageToken: String?
    private var isFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        configureNavigationBar()
        configureUI()
        setupFavoriteButton()
        checkIfFavorite()
    }

    deinit {
        ImageLoader.shared.cancel(imageToken)
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
        let ngo = self.ngo!

        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit

        let placeholder = UIImage(named: "ngo_placeholder") ?? UIImage(systemName: "photo")
        imageView.image = placeholder

        let v = ngo.imageName.trimmingCharacters(in: .whitespacesAndNewlines)

        if v.lowercased().hasPrefix("http://") || v.lowercased().hasPrefix("https://") {
            imageToken = ImageLoader.shared.load(v, into: imageView, placeholder: placeholder)
        } else {
            ImageLoader.shared.cancel(imageToken)
            imageToken = nil
            imageView.image = UIImage(named: v) ?? placeholder
        }

        nameLabel.text = ngo.name
        ratingLabel.text = "\(ngo.rating) (\(ngo.reviews))"
        descriptionLabel.text = ngo.fullDescription

        phoneInfoLabel.text = "Contact us: \(ngo.phone)"
        emailLabel.text = "Email: \(ngo.email)"
        addressLabel.text = "Address: \(ngo.address)"
    }

    // MARK: - Favorites (Firestore)
    private func setupFavoriteButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "heart"),
            style: .plain,
            target: self,
            action: #selector(toggleFavorite)
        )
    }

    private func updateFavoriteIcon() {
        let name = isFavorite ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: name)
    }

    private func favoriteDocRef() -> DocumentReference {
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(ngo.id) // IMPORTANT: uses ngo doc id from ngo_reviews
    }

    private func checkIfFavorite() {
        if ngo.id.isEmpty {
            print("❌ ngo.id is empty (should be Firestore doc id).")
            return
        }

        favoriteDocRef().getDocument { [weak self] doc, error in
            guard let self else { return }

            if let error = error {
                print("❌ checkIfFavorite error:", error.localizedDescription)
                return
            }

            self.isFavorite = (doc?.exists == true)
            self.updateFavoriteIcon()
            print("✅ isFavorite =", self.isFavorite, "for ngoId =", self.ngo.id)
        }
    }

    @objc private func toggleFavorite() {
        if ngo.id.isEmpty {
            print("❌ ngo.id is empty (cannot favorite).")
            return
        }

        if isFavorite {
            favoriteDocRef().delete { [weak self] error in
                guard let self else { return }

                if let error = error {
                    print("❌ Remove favorite failed:", error.localizedDescription)
                    return
                }

                self.isFavorite = false
                self.updateFavoriteIcon()
                print("✅ Removed from favorites:", self.ngo.id)
            }
        } else {
            favoriteDocRef().setData([
                "ngoId": ngo.id,
                "createdAt": FieldValue.serverTimestamp()
            ], merge: true) { [weak self] error in
                guard let self else { return }

                if let error = error {
                    print("❌ Add favorite failed:", error.localizedDescription)
                    return
                }

                self.isFavorite = true
                self.updateFavoriteIcon()
                print("✅ Added to favorites:", self.ngo.id)
            }
        }
    }

    // MARK: - Actions
    @IBAction func phoneTapped(_ sender: UIButton) {
        let cleanNumber = ngo.phone.filter { "0123456789+".contains($0) }

        let alert = UIAlertController(title: "Call NGO", message: ngo.phone, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Call", style: .default) { _ in
            if let url = URL(string: "tel://\(cleanNumber)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @IBAction func messageTapped(_ sender: UIButton) {
        let cleanNumber = ngo.phone.filter { "0123456789+".contains($0) }

        let alert = UIAlertController(title: "Message", message: "Send message to \(ngo.name)", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Message", style: .default) { _ in
            if let url = URL(string: "sms:\(cleanNumber)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
