import UIKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var historyImageView: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var currentStatusLabel: UILabel!   // Top status
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickupDateLabel: UILabel!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var finalStatusLabel: UILabel!     // Bottom status
    
    
    var selectedHistory: DonationHistory?
    
    
    var onDetailsTapped: (() -> Void)?

        @IBAction func detailsButtonTapped(_ sender: UIButton) {
            onDetailsTapped?()
        }


    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter
    }()

    func configure(with history: DonationHistory) {
        historyImageView.image = UIImage(named: history.imageName)
        restaurantLabel.text = history.restaurantName
        
        // Current status at top
        currentStatusLabel.text = history.currentStatus
        switch history.currentStatus.lowercased() {
        case "donated":
            currentStatusLabel.textColor = .systemGreen
        case "canceled":
            currentStatusLabel.textColor = .systemRed
        case "pending":
            currentStatusLabel.textColor = .systemOrange
        default:
            currentStatusLabel.textColor = .label
        }
        
        // Items + quantity
        itemsLabel.text = "Items: \(history.itemsWithQuantity)"
        
        // Date and pickup
        dateLabel.text = dateFormatter.string(from: history.date)
        pickupDateLabel.text = "Pickup: \(dateFormatter.string(from: history.pickupDate))"
        
        // Final status at bottom
        finalStatusLabel.text = "Status: \(history.finalStatus)"
        switch history.finalStatus.lowercased() {
        case "completed":
            finalStatusLabel.textColor = .systemGreen
        case "canceled":
            finalStatusLabel.textColor = .systemRed
        default:
            finalStatusLabel.textColor = .label
        }
    }
}
