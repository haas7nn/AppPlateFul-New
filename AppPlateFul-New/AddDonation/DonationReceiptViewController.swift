import UIKit

class DonationReceiptViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var itemValueLabel: UILabel!
    @IBOutlet weak var donatedToValueLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var statusValueLabel: UILabel!
    @IBOutlet weak var receiptCard: UIView!
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var merchantLabel: UILabel!
    @IBOutlet weak var specialNotesLabel: UILabel!
    
    // MARK: - Properties
    var itemName: String = "Chicken Shawarma Meal"
    var quantity: Int = 0
    var donatedTo: String = "Helping Hands"
    var merchantName: String = "Alfreej Shawarma's"
    var specialNotes: String = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCardShadow()
        setupButtonShadow()
        populateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - Setup
    private func setupCardShadow() {
        receiptCard.layer.cornerRadius = 20
        receiptCard.layer.shadowColor = UIColor.black.cgColor
        receiptCard.layer.shadowOpacity = 0.15
        receiptCard.layer.shadowOffset = CGSize(width: 0, height: 4)
        receiptCard.layer.shadowRadius = 12
        receiptCard.layer.masksToBounds = false
    }
    
    private func setupButtonShadow() {
        scanButton.layer.cornerRadius = 24
        scanButton.layer.shadowColor = UIColor.black.cgColor
        scanButton.layer.shadowOpacity = 0.2
        scanButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        scanButton.layer.shadowRadius = 8
        scanButton.layer.masksToBounds = false
    }
    
    private func populateData() {
        merchantLabel.text = merchantName
        itemValueLabel.text = "\(itemName) (x\(quantity))"
        donatedToValueLabel.text = donatedTo
        dateValueLabel.text = getCurrentDateTime()
        statusValueLabel.text = "Completed"
        
        // Show special notes if available
        if specialNotes.isEmpty {
            specialNotesLabel.isHidden = true
        } else {
            specialNotesLabel.isHidden = false
            specialNotesLabel.text = specialNotes
        }
    }
    
    private func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy – h:mm a"
        return formatter.string(from: Date())
    }
    
    // MARK: - Actions
    @IBAction func backTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        var shareText = "I donated \(quantity) \(itemName) to \(donatedTo) via PlateFul! 🍽️"
        if !specialNotes.isEmpty {
            shareText += "\n\n\(specialNotes)"
        }
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    @IBAction func scanTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "QR Scanner", message: "QR scanning coming soon!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
