import UIKit

class DonationsListViewController: UIViewController {
    
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var collectedPopup: UIView!
    @IBOutlet weak var canceledPopup: UIView!
    
    private var card1StatusLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLogos()
        findCard1StatusLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCard1Status()
    }
    
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopups))
        overlayBackground.addGestureRecognizer(tapGesture)
    }
    
    private func findCard1StatusLabel() {
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first {
            
            for cardView in contentView.subviews {
                // Card 1 is at y position < 100
                if cardView.frame.origin.y < 100 && cardView.frame.height == 140 {
                    // Find the status label (contains "Status:")
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
    
    private func updateCard1Status() {
        let savedState = UserDefaults.standard.integer(forKey: "alfreejDonationState")
        let state = DonationState(rawValue: savedState) ?? .awaitingAcceptance
        
        guard let statusLabel = card1StatusLabel else { return }
        
        let statusText = state.listStatusText
        let fullText = "Status: \(statusText)"
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // "Status: " in gray
        let prefixRange = NSRange(location: 0, length: 8)
        attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0), range: prefixRange)
        
        // Status value color based on state
        let valueRange = NSRange(location: 8, length: statusText.count)
        let valueColor: UIColor
        
        switch state {
        case .awaitingAcceptance:
            valueColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0) // Gray
        case .orderBeingPrepared:
            valueColor = UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) // Green
        case .orderBeingDelivered:
            valueColor = UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) // Green
        case .orderCompleted:
            valueColor = UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) // Green
        }
        
        attributedString.addAttribute(.foregroundColor, value: valueColor, range: valueRange)
        statusLabel.attributedText = attributedString
    }
    
    private func setupLogos() {
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first {
            
            for cardView in contentView.subviews {
                for subview in cardView.subviews {
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
    
    private func addImageToView(_ view: UIView, imageName: String) {
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func card1Tapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "DonationsList", bundle: nil)
        if let detailsVC = storyboard.instantiateViewController(withIdentifier: "DonationDetailsViewController") as? DonationDetailsViewController {
            detailsVC.modalPresentationStyle = .fullScreen
            detailsVC.onStatusChanged = { [weak self] state in
                self?.updateCard1Status()
            }
            present(detailsVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func card2Tapped(_ sender: Any) {
        showPopup(popup: collectedPopup)
    }
    
    @IBAction func card3Tapped(_ sender: Any) {
        showPopup(popup: canceledPopup)
    }
    
    private func showPopup(popup: UIView) {
        overlayBackground.alpha = 0
        popup.alpha = 0
        popup.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        overlayBackground.isHidden = false
        popup.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.overlayBackground.alpha = 1
            popup.alpha = 1
            popup.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.dismissPopups()
        }
    }
    
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
