import UIKit

// Tracks the state of a single donation as it moves through the flow.
enum DonationState: Int {
    case awaitingAcceptance = 0     // driver has not accepted it yet
    case orderBeingPrepared = 1     // accepted / preparing
    case orderBeingDelivered = 2    // on the way
    case orderCompleted = 3         // delivered
    
    // Text used in the main donations list for each state
    var listStatusText: String {
        switch self {
        case .awaitingAcceptance:
            return "Awaiting pickup"
        case .orderBeingPrepared:
            return "Accepted"
        case .orderBeingDelivered:
            return "Collected"
        case .orderCompleted:
            return "Delivered"
        }
    }
}

// Detail screen for a single donation (used by driver / volunteer).
class DonationDetailsViewController: UIViewController {
    
    // Main button at the bottom ("Accept", "Picked up", "Delivered"...)
    @IBOutlet weak var actionButton: UIButton!
    
    // Label at the top: "Status: Order Being Delivered"
    @IBOutlet weak var statusCombinedLabel: UILabel!
    
    // Dimmed background + popup used for success messages
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var successPopup: UIView!
    @IBOutlet weak var successTitle: UILabel!
    @IBOutlet weak var successBody: UILabel!
    
    // Current status of this donation on the detail screen
    private var currentState: DonationState = .awaitingAcceptance
    
    // Called when we go back so the main list can update its status text
    var onStatusChanged: ((DonationState) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedState()          // restore last state from UserDefaults
        setupUI()                 // gestures / basic setup
        setupMealImage()          // set the big food image once
        updateUIForCurrentState() // update texts and button title
    }
    
    // MARK: - Persistence
    
    // Reads previously saved state for this donation (so it survives relaunch)
    private func loadSavedState() {
        let savedState = UserDefaults.standard.integer(forKey: "alfreejDonationState")
        currentState = DonationState(rawValue: savedState) ?? .awaitingAcceptance
    }
    
    // Saves the current state to UserDefaults
    private func saveState() {
        UserDefaults.standard.set(currentState.rawValue, forKey: "alfreejDonationState")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Tapping anywhere on the dark overlay closes the popup
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        overlayBackground.addGestureRecognizer(tapGesture)
    }
    
    // Looks for the meal image placeholder in the scroll view and sets a static image
    private func setupMealImage() {
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first {
            
            for subview in contentView.subviews {
                if subview.frame.width == 300 && subview.frame.height == 220 {
                    for cardSubview in subview.subviews {
                        // Case 1: placeholder is already an UIImageView
                        if cardSubview is UIImageView {
                            let imageView = cardSubview as! UIImageView
                            imageView.image = UIImage(named: "shawarma_image")
                            imageView.contentMode = .scaleAspectFill
                            imageView.clipsToBounds = true
                            return
                        }
                        // Case 2: placeholder is a plain view, so we insert the image view
                        else if cardSubview.frame.width == 280 && cardSubview.frame.height == 200 {
                            let imageView = UIImageView(frame: cardSubview.bounds)
                            imageView.image = UIImage(named: "shawarma_image")
                            imageView.contentMode = .scaleAspectFill
                            imageView.clipsToBounds = true
                            imageView.layer.cornerRadius = 12
                            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                            cardSubview.addSubview(imageView)
                            return
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backTapped(_ sender: Any) {
        // Notify the previous screen of the final state, then close
        onStatusChanged?(currentState)
        dismiss(animated: true, completion: nil)
    }
    
    // Main button at the bottom advances the state machine step by step
    @IBAction func actionButtonTapped(_ sender: Any) {
        switch currentState {
        case .awaitingAcceptance:
            // Step 1 -> 2
            showSuccessPopup(title: "Successfully Accepted",
                             body: "Please head to designated location and collect order")
            currentState = .orderBeingPrepared
            saveState()
            
        case .orderBeingPrepared:
            // Step 2 -> 3
            showSuccessPopup(title: "Order Picked Up!",
                             body: "Please head to designated location and deliver order")
            currentState = .orderBeingDelivered
            saveState()
            
        case .orderBeingDelivered:
            // Step 3 -> 4
            showSuccessPopup(title: "Order Delivered!",
                             body: "Thank you for delivering this order!")
            currentState = .orderCompleted
            saveState()
            
        case .orderCompleted:
            // Nothing more to do
            break
        }
    }
    
    // Updates labels & button text based on currentState
    private func updateUIForCurrentState() {
        switch currentState {
        case .awaitingAcceptance:
            statusCombinedLabel.isHidden = true
            actionButton.setTitle("Accept Donation", for: .normal)
            actionButton.backgroundColor = UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0)
            actionButton.isEnabled = true
            
        case .orderBeingPrepared:
            statusCombinedLabel.isHidden = false
            setStatusText(status: "Order Being Prepared")
            actionButton.setTitle("Order Picked up", for: .normal)
            actionButton.backgroundColor = UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0)
            actionButton.isEnabled = true
            
        case .orderBeingDelivered:
            statusCombinedLabel.isHidden = false
            setStatusText(status: "Order Being Delivered")
            actionButton.setTitle("Order Delivered", for: .normal)
            actionButton.backgroundColor = UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0)
            actionButton.isEnabled = true
            
        case .orderCompleted:
            statusCombinedLabel.isHidden = false
            setStatusText(status: "Order Completed")
            actionButton.setTitle("Order Completed", for: .normal)
            actionButton.backgroundColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
            actionButton.isEnabled = false
        }
    }
    
    // Builds an attributed string like "Status: Order Being Delivered"
    // with "Status:" in dark color and the value in green.
    private func setStatusText(status: String) {
        let fullText = "Status: \(status)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let statusRange = NSRange(location: 0, length: 8)
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0),
                                      range: statusRange)
        
        let valueRange = NSRange(location: 8, length: status.count)
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0),
                                      range: valueRange)
        
        statusCombinedLabel.attributedText = attributedString
    }
    
    // Shows the overlay + popup with a specific title/body, then hides it after 2.5s
    private func showSuccessPopup(title: String, body: String) {
        successTitle.text = title
        successBody.text = body
        
        overlayBackground.alpha = 0
        successPopup.alpha = 0
        successPopup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        overlayBackground.isHidden = false
        successPopup.isHidden = false
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.overlayBackground.alpha = 1
            self.successPopup.alpha = 1
            self.successPopup.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.dismissPopup()
        }
    }
    
    // Closes the popup and refreshes the UI for the new state
    @objc private func dismissPopup() {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlayBackground.alpha = 0
            self.successPopup.alpha = 0
            self.successPopup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.overlayBackground.isHidden = true
            self.successPopup.isHidden = true
            self.successPopup.transform = .identity
            self.updateUIForCurrentState()
        }
    }
}
