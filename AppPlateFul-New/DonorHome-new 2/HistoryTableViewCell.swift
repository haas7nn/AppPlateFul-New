import UIKit

class HistoryTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var historyImageView: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickupDateLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var finalStatusLabel: UILabel!

    // MARK: - Callback
    var onDetailsTapped: (() -> Void)?

    @IBAction func detailsButtonTapped(_ sender: UIButton) {
        onDetailsTapped?()
    }

    // MARK: - Formatter
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter
    }()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Keep details button as storyboard configured
        detailsButton.isHidden = false
        
        // If it's a system image button (SF Symbol), set tint color so it shows
        detailsButton.tintColor = .systemBlue // or whatever color you want

        // Rounded edges for the image
        historyImageView.layer.cornerRadius = 12  // adjust as needed
        historyImageView.clipsToBounds = true
        historyImageView.contentMode = .scaleAspectFill
    }


    // MARK: - Configure Cell
    func configure(with donation: Donation) {
        restaurantLabel.text = donation.donorName
        itemsLabel.text = "Items: \(donation.title) (\(donation.quantity))"
        
        detailsButton.alpha = 1
        detailsButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)

        // Status
        currentStatusLabel.text = donation.status.rawValue.capitalized
        switch donation.status {
        case .pending:
            currentStatusLabel.textColor = .systemOrange
        case .accepted, .toBeApproved, .toBeCollected:
            currentStatusLabel.textColor = .systemBlue
        case .completed:
            currentStatusLabel.textColor = .systemGreen
        case .cancelled:
            currentStatusLabel.textColor = .systemRed
        }

        finalStatusLabel.text = "Status: \(donation.status.rawValue.capitalized)"
        finalStatusLabel.textColor = currentStatusLabel.textColor

        // Dates
        dateLabel.text = donation.expiryDate.map { dateFormatter.string(from: $0) } ?? "Date: —"
        pickupDateLabel.text = donation.scheduledPickup.map { "Pickup: \(dateFormatter.string(from: $0.pickupDate))" } ?? "Pickup: Not scheduled"

        // Load image from Firebase URL using ImageLoader
        if !donation.imageRef.isEmpty {
            ImageLoader.shared.load(donation.imageRef) { [weak self] image in
                DispatchQueue.main.async {
                    self?.historyImageView.image = image ?? UIImage(systemName: "photo")
                }
            }
        } else {
            historyImageView.image = UIImage(systemName: "photo")
        }
    }
}
