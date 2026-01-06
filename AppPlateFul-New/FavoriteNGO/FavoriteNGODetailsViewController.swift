import UIKit

final class FavoriteNGODetailsViewController: UIViewController {

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

    // MARK: - Data
    var ngo: FavoriteNGO!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Details"
        configureNavigationBar()
        configureUI()
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
        guard let ngo = ngo else {
            fatalError("FavoriteNGO not injected")
        }

        // Image - remove gray background
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        
        if let image = UIImage(named: ngo.imageName) {
            imageView.image = image
        } else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .lightGray
            imageView.backgroundColor = UIColor(white: 0.95, alpha: 1) 
        }

        // Name & Rating
        nameLabel.text = ngo.name
        ratingLabel.text = "\(ngo.rating) (\(ngo.reviews))"

        // Full description for details page
        descriptionLabel.text = ngo.fullDescription

        // Contact Info
        phoneInfoLabel.text = "Contact us: \(ngo.phone)"
        emailLabel.text = "Email: \(ngo.email)"
        addressLabel.text = "Address: \(ngo.address)"
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
