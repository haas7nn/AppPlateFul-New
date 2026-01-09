import UIKit

/// This view controller handles the "Track Order" screen,
/// including showing a confirmation dialog when the user marks an order as delivered.
class TrackingOrderViewController: UIViewController {
    
    // MARK: - Outlets (connected from Storyboard)
    
    /// Button the user taps to confirm that the order has been delivered.
    @IBOutlet weak var confirmButton: UIButton!
    
    /// Label that shows the final delivered time.
    @IBOutlet weak var deliveredTimeLabel: UILabel!
    
    /// Semi-transparent background view shown behind the success dialog (the dark overlay).
    @IBOutlet weak var overlayBackground: UIView!
    
    /// Label that shows the time for step 1 in the tracking process.
    @IBOutlet weak var step1TimeLabel: UILabel!
    
    /// Label that shows the time for step 2 in the tracking process.
    @IBOutlet weak var step2TimeLabel: UILabel!
    
    /// Label that shows the time for step 3 in the tracking process.
    @IBOutlet weak var step3TimeLabel: UILabel!
    
    /// The success dialog view that pops up after confirming delivery.
    @IBOutlet weak var successDialog: UIView!
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up initial UI behavior, such as gestures for dismissing the dialog.
        setupUI()
    }
    
    
    // MARK: - Setup
    
    /// Configures UI elements and interactions when the view loads.
    private func setupUI() {
        // Add a tap gesture recognizer to the dark overlay background
        // so the user can dismiss the success dialog by tapping outside of it.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        overlayBackground.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Actions (triggered by buttons)
    
    /// Called when the back button is tapped.
    /// Dismisses this view controller and returns to the previous screen.
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when the "Confirm Delivery" button is tapped.
    /// Shows the success dialog with an animation.
    @IBAction func confirmDeliveryTapped(_ sender: Any) {
        showSuccessDialog()
    }
    
    
    // MARK: - Dialog Methods
    
    /// Shows the success dialog with a spring animation
    /// and automatically hides it after a short delay.
    private func showSuccessDialog() {
        // Start with the overlay and dialog fully transparent and slightly scaled down.
        overlayBackground.alpha = 0
        successDialog.alpha = 0
        successDialog.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        // Make sure both views are visible in the view hierarchy.
        overlayBackground.isHidden = false
        successDialog.isHidden = false
        
        // Animate the dialog appearing:
        // - Fade in the overlay
        // - Fade in the dialog
        // - Scale the dialog up to its normal size with a spring effect
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,   // Controls how "bouncy" the animation is (lower = more bounce).
            initialSpringVelocity: 0.5,    // Controls how fast the animation starts.
            options: .curveEaseOut         // Slows down smoothly at the end.
        ) {
            self.overlayBackground.alpha = 1
            self.successDialog.alpha = 1
            self.successDialog.transform = .identity
        }
        
        // Automatically dismiss the dialog after 2.5 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.dismissDialog()
        }
    }
    
    /// Hides the success dialog with a fade-and-scale animation.
    /// This can be triggered either automatically or by tapping the overlay.
    @objc private func dismissDialog() {
        UIView.animate(withDuration: 0.25, animations: {
            // Fade out the overlay and dialog, and slightly scale down the dialog.
            self.overlayBackground.alpha = 0
            self.successDialog.alpha = 0
            self.successDialog.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            // After the animation finishes:
            // - Hide the views so they don't block touches
            // - Reset the transform so the view is back to normal for next time
            self.overlayBackground.isHidden = true
            self.successDialog.isHidden = true
            self.successDialog.transform = .identity
        }
    }
}
