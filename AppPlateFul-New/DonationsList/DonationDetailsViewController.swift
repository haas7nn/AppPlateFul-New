import UIKit

enum DonationState: Int {
    case awaitingAcceptance = 0
    case orderBeingPrepared = 1
    case orderBeingDelivered = 2
    case orderCompleted = 3
}

class DonationDetailsViewController: UIViewController {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var statusCombinedLabel: UILabel!
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var successPopup: UIView!
    @IBOutlet weak var successTitle: UILabel!
    @IBOutlet weak var successBody: UILabel!
    
    private var currentState: DonationState = .awaitingAcceptance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMealImage()
        updateUIForCurrentState()
    }
    
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        overlayBackground.addGestureRecognizer(tapGesture)
    }
    
    private func setupMealImage() {
        // Find the meal image view by traversing the view hierarchy
        // Look for the ScrollView -> ContentView -> MealCard -> ImageView
        
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first {
            
            // Find the meal card (first white view with width 300)
            for subview in contentView.subviews {
                if subview.frame.width == 300 && subview.frame.height == 220 {
                    // This is the meal card
                    // Find the image view inside
                    for cardSubview in subview.subviews {
                        if cardSubview is UIImageView {
                            let imageView = cardSubview as! UIImageView
                            imageView.image = UIImage(named: "shawarma_image")
                            imageView.contentMode = .scaleAspectFill
                            imageView.clipsToBounds = true
                            return
                        } else if cardSubview.frame.width == 280 && cardSubview.frame.height == 200 {
                            // This might be a placeholder view, add image to it
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
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionButtonTapped(_ sender: Any) {
        switch currentState {
        case .awaitingAcceptance:
            showSuccessPopup(title: "Successfully Accepted", body: "Please head to designated location and collect order")
            currentState = .orderBeingPrepared
            
        case .orderBeingPrepared:
            showSuccessPopup(title: "Order Picked Up!", body: "Please head to designated location and deliver order")
            currentState = .orderBeingDelivered
            
        case .orderBeingDelivered:
            showSuccessPopup(title: "Order Delivered!", body: "Thank you for delivering this order!")
            currentState = .orderCompleted
            
        case .orderCompleted:
            break
        }
    }
    
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
    
    private func setStatusText(status: String) {
        let fullText = "Status: \(status)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let statusRange = NSRange(location: 0, length: 8)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.067, green: 0.067, blue: 0.067, alpha: 1.0), range: statusRange)
        
        let valueRange = NSRange(location: 8, length: status.count)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0), range: valueRange)
        
        statusCombinedLabel.attributedText = attributedString
    }
    
    private func showSuccessPopup(title: String, body: String) {
        successTitle.text = title
        successBody.text = body
        
        overlayBackground.alpha = 0
        successPopup.alpha = 0
        successPopup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        overlayBackground.isHidden = false
        successPopup.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.overlayBackground.alpha = 1
            self.successPopup.alpha = 1
            self.successPopup.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.dismissPopup()
        }
    }
    
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
