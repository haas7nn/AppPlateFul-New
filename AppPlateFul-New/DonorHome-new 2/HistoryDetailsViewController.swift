import UIKit

class HistoryDetailsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickupDateLabel: UILabel!
    @IBOutlet weak var finalStatusLabel: UILabel!

    // MARK: - Properties
    var donation: Donation?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makeImageCornersRounded()
    }

    private func setupUI() {
        guard let donation = donation else { return }

        restaurantLabel.text = donation.donorName
        itemsLabel.text = "Items: \(donation.title) (\(donation.quantity))"
        dateLabel.text = donation.expiryDate.map { dateFormatter.string(from: $0) } ?? "Date: —"
        pickupDateLabel.text = donation.scheduledPickup.map { "Pickup: \(dateFormatter.string(from: $0.pickupDate))" } ?? "Pickup: Not scheduled"
        finalStatusLabel.text = "Status: \(donation.status.rawValue.capitalized)"

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        // Load image using ImageLoader
        if !donation.imageRef.isEmpty {
            ImageLoader.shared.load(donation.imageRef) { [weak self] image in
                DispatchQueue.main.async {
                    self?.imageView.image = image ?? UIImage(systemName: "photo")
                }
            }
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }

    private func makeImageCornersRounded() {
        imageView.layer.cornerRadius = 12  // adjust this for more/less rounding
    }
}
