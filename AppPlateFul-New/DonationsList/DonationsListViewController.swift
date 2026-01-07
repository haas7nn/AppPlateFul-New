import UIKit

class DonationsListViewController: UIViewController {
    
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var collectedPopup: UIView!
    @IBOutlet weak var canceledPopup: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLogos()
    }
    
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopups))
        overlayBackground.addGestureRecognizer(tapGesture)
    }
    
    private func setupLogos() {
        // Find logo views by tag or by traversing the view hierarchy
        // We'll find them by looking for views with specific background colors and sizes
        
        if let scrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView,
           let contentView = scrollView.subviews.first {
            
            // Find all card views (white background, height 140)
            for cardView in contentView.subviews {
                // Find the logo placeholder view inside each card (80x80 gray view)
                for subview in cardView.subviews {
                    if subview.frame.width == 80 && subview.frame.height == 80 {
                        // This is a logo placeholder
                        // Determine which card based on position
                        if cardView.frame.origin.y < 100 {
                            // Card 1 - Alfreej Shawarma's
                            addImageToView(subview, imageName: "alfreej_logo")
                        } else if cardView.frame.origin.y < 250 {
                            // Card 2 - Chocologi Cafe
                            addImageToView(subview, imageName: "chocologi_logo")
                        } else {
                            // Card 3 - It's Just Wings
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
