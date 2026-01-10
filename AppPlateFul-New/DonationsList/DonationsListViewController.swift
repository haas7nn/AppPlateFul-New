import UIKit

// Screen that shows three sample donation cards for the donor.
class DonationsListViewController: UIViewController {
    
    // Dark overlay + two popups for cards 2 (collected) and 3 (canceled)
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var collectedPopup: UIView!
    @IBOutlet weak var canceledPopup: UIView!
    
    // Reference to the status label on the first card (Alfreej)
    private var card1StatusLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()          // tap gesture for dismissing popups
        setupLogos()       // put logos into the three cards
        findCard1StatusLabel()  // locate the "Status:" label in the first card
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Every time we come back from the details screen, update status text
        updateCard1Status()
    }
    
    // MARK: - Setup
    
    // Add tap on the overlay to close any open popup
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopups))
        overlayBackground.addGestureRecognizer(tapGesture)
    }
    
    // Find the status label in the first card by walking the view hierarchy
    private func findCard1StatusLabel() {
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first {
            
            for cardView in contentView.subviews {
                
                // Very first card: near the top and height ~140
                if cardView.frame.origin.y < 100 && cardView.frame.height == 140 {
                    // Inside that card, find the label that contains "Status:"
                    for subview in cardView.subviews {
                        if let label = subview as? UILabel,
                           let text = label.text,
                           text.contains("Status:") {
                            card1StatusLabel = label
                            return
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Card 1 status (driven by DonationDetailsViewController)
    
    // Update the first card's status label based on the saved DonationState
    private func updateCard1Status() {
        let savedState = UserDefaults.standard.integer(forKey: "alfreejDonationState")
        let state = DonationState(rawValue: savedState) ?? .awaitingAcceptance
        
        guard let statusLabel = card1StatusLabel else { return }
        
        let statusText = state.listStatusText              // e.g. "Collected"
        let fullText = "Status: \(statusText)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // "Status: " part (always gray)
        let prefixRange = NSRange(location: 0, length: 8)
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
                                      range: prefixRange)
        
        // Value part ("Awaiting pickup", "Collected", ...)
        let valueRange = NSRange(location: 8, length: statusText.count)
        let valueColor: UIColor
        
        switch state {
        case .awaitingAcceptance:
            valueColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Gray
        case .orderBeingPrepared,
             .orderBeingDelivered,
             .orderCompleted:
            valueColor = UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) // Green
        }
        
        attributedString.addAttribute(.foregroundColor, value: valueColor, range: valueRange)
        statusLabel.attributedText = attributedString
    }
    
    // MARK: - Logos for the three cards
    
    // Inserts the correct logo inside each card by looking at its position
    private func setupLogos() {
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first {
            
            for cardView in contentView.subviews {
                for subview in cardView.subviews {
                    // We treat any 80x80 view as the logo container
                    if subview.frame.width == 80 && subview.frame.height == 80 {
                        if cardView.frame.origin.y < 100 {
                            addImageToView(subview, imageName: "alfreej_logo")
                        } else if cardView.frame.origin.y < 250 {
                            addImageToView(subview, imageName: "chocologi_logo")
                        } else {
                            addImageToView(subview, imageName: "justwings_logo")
                        }
                    }
                }
            }
        }
    }
    
    // Helper to drop a UIImageView into a placeholder view
    private func addImageToView(_ view: UIView, imageName: String) {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
    }
    
    // MARK: - Navigation / Card taps
    
    @IBAction func backTapped(_ sender: Any) {
        // Close this list screen (it was presented modally)
        dismiss(animated: true, completion: nil)
    }
    
    // First card (Alfreej) opens the interactive details screen
    @IBAction func card1Tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DonationsList", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "DonationDetailsViewController") as? DonationDetailsViewController {
            detailsVC.modalPresentationStyle = .fullScreen
            // When the user finishes updating the state, refresh the card status
            detailsVC.onStatusChanged = { [weak self] state in
                self?.updateCard1Status()
            }
            present(detailsVC, animated: true, completion: nil)
        }
    }
    
    // Second card shows a "collected" info popup
    @IBAction func card2Tapped(_ sender: Any) {
        showPopup(popup: collectedPopup)
    }
    
    // Third card shows a "canceled" info popup
    @IBAction func card3Tapped(_ sender: Any) {
        showPopup(popup: canceledPopup)
    }
    
    // MARK: - Popups
    
    // Common animation for both popups
    private func showPopup(popup: UIView) {
        overlayBackground.alpha = 0
        popup.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        overlayBackground.isHidden = false
        popup.isHidden = false
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.overlayBackground.alpha = 1
            popup.alpha = 1
            popup.transform = .identity
        }
        
        // Auto-hide after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismissPopups()
        }
    }
    
    // Hides both popups and the overlay
    @objc private func dismissPopups() {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlayBackground.alpha = 0
            self.collectedPopup.alpha = 0
            self.canceledPopup.alpha = 0
            self.collectedPopup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.canceledPopup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.overlayBackground.isHidden = true
            self.collectedPopup.isHidden = true
            self.canceledPopup.isHidden = true
            self.collectedPopup.transform = .identity
            self.canceledPopup.transform = .identity
        }
    }
}
