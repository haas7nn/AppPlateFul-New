import UIKit

class TrackingOrderViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var deliveredTimeLabel: UILabel!
    @IBOutlet weak var overlayBackground: UIView!
    @IBOutlet weak var step1TimeLabel: UILabel!
    @IBOutlet weak var step2TimeLabel: UILabel!
    @IBOutlet weak var step3TimeLabel: UILabel!
    @IBOutlet weak var successDialog: UIView!
    
    
    @IBOutlet weak var deliveredStatusLabel: UILabel!
    @IBOutlet weak var step3DotView: UIView!
    @IBOutlet weak var step3TitleLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        
        
        // Tap on overlay to dismiss dialog
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        overlayBackground.addGestureRecognizer(tapGesture)
        
        // Dialog hidden initially
        overlayBackground.isHidden = true
        successDialog.isHidden = true
        
        // 1) Only times (no dates)
        step1TimeLabel.text = "05:40 PM"
        step2TimeLabel.text = "05:44 PM"
        step3TimeLabel.text = "06:03 PM"
        
        // 2) Initial status: ON THE WAY (not delivered)
        deliveredStatusLabel.text = "On the Way"
        deliveredTimeLabel.text = step2TimeLabel.text  // show second step time
        
        // 3) Hide Delivered row (step 3) until user confirms
        step3DotView.isHidden = true
        step3TitleLabel.isHidden = true
        step3TimeLabel.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        title = "Tracking order"
    }
    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        
    }
    
    @IBAction func confirmDeliveryTapped(_ sender: Any) {
        
        deliveredStatusLabel.text = "Delivered"
        deliveredTimeLabel.text = step3TimeLabel.text
        
        step3DotView.isHidden = false
        step3TitleLabel.isHidden = false
        step3TimeLabel.isHidden = false
        
        showSuccessDialog()
    }
    
    // MARK: - Dialog Methods
    private func showSuccessDialog() {
        overlayBackground.alpha = 0
        successDialog.alpha = 0
        successDialog.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        overlayBackground.isHidden = false
        successDialog.isHidden = false
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut) {
            self.overlayBackground.alpha = 1
            self.successDialog.alpha = 1
            self.successDialog.transform = .identity
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.dismissDialog()
        }
    }
    
    @objc private func dismissDialog() {
        UIView.animate(withDuration: 0.25, animations: {
            self.overlayBackground.alpha = 0
            self.successDialog.alpha = 0
            self.successDialog.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.overlayBackground.isHidden = true
            self.successDialog.isHidden = true
            self.successDialog.transform = .identity
        }
    }
}
