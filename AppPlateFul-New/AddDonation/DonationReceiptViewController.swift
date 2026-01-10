import UIKit

// Screen that shows a simple receipt after a donation is submitted.
class DonationReceiptViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemValueLabel: UILabel!      // shows item name + quantity
    @IBOutlet weak var dateValueLabel: UILabel!      // shows when the donation was completed
    @IBOutlet weak var statusValueLabel: UILabel!    // used here to show the expiry date
    @IBOutlet weak var receiptCard: UIView!          // white card in the middle
    @IBOutlet weak var scanButton: UIButton!         // round button with QR icon
    @IBOutlet weak var merchantLabel: UILabel!       // currently hidden (we don't show merchant here)
    @IBOutlet weak var specialNotesLabel: UILabel!   // shows donation + health notes if any
    
    // MARK: - Properties passed in from AddDonationViewController
    var itemName: String = "Chicken Shawarma Meal"
    var quantity: Int = 0
    var donatedTo: String = "Helping Hands"
    var merchantName: String = "Alfreej Shawarma's"
    var specialNotes: String = ""
    
    // expiry date passed from AddDonationViewController
    var expiryDate: Date?
    
    // Used to format the expiry date text
    private let expiryFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy"
        return f
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardShadow()
        setupButtonShadow()
        populateData()   // fill labels with the values we got
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide nav bar so the custom top design is used
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    
    // Add shadow and rounded corners to the receipt card
    private func setupCardShadow() {
        receiptCard.layer.cornerRadius = 20
        receiptCard.layer.shadowColor = UIColor.black.cgColor
        receiptCard.layer.shadowOpacity = 0.15
        receiptCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        receiptCard.layer.shadowRadius = 12
        receiptCard.layer.masksToBounds = false
    }
    
    // Add shadow to the scan button
    private func setupButtonShadow() {
        scanButton.layer.cornerRadius = 24
        scanButton.layer.shadowColor = UIColor.black.cgColor
        scanButton.layer.shadowOpacity = 0.2
        scanButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        scanButton.layer.shadowRadius = 8
        scanButton.layer.masksToBounds = false
    }
    
    // Fill all labels based on the data passed from AddDonation
    private func populateData() {
        // We don't want to show merchant line on this design
        merchantLabel.isHidden = true
        merchantLabel.text = ""
        
        // Example: "Shawarma (x4)"
        itemValueLabel.text = "\(itemName) (x\(quantity))"
        
        // Top line: when the donation was completed (current time)
        dateValueLabel.text = getCurrentDateTime()
        
        // Status line now means "Expiry Date"
        if let exp = expiryDate {
            statusValueLabel.text = expiryFormatter.string(from: exp)
        } else {
            statusValueLabel.text = "-"
        }
        
        // Show notes only if we actually have any
        if specialNotes.isEmpty {
            specialNotesLabel.isHidden = true
        } else {
            specialNotesLabel.isHidden = false
            specialNotesLabel.text = specialNotes
        }
    }
    
    // Helper to format the completion date/time
    private func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy – h:mm a"
        return formatter.string(from: Date())
    }
    
    // MARK: - Actions
    
    // Back button closes the receipt and returns to the root (home)
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // Share button builds a simple summary text and opens the iOS share sheet
    @IBAction func shareTapped(_ sender: UIButton) {
        var shareText = "I donated \(quantity) \(itemName) to \(donatedTo) via PlateFul! 🍽️"
        if !specialNotes.isEmpty {
            shareText += "\n\n\(specialNotes)"
        }
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // Scan button currently just shows a placeholder alert
    @IBAction func scanTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "QR Scanner", message: "QR scanning coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
