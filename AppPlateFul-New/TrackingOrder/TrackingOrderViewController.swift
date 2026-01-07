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
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissDialog))
        overlayBackground.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmDeliveryTapped(_ sender: Any) {
        showSuccessDialog()
    }
    
    // MARK: - Dialog Methods
    private func showSuccessDialog() {
        overlayBackground.alpha = 0
        successDialog.alpha = 0
        successDialog.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        overlayBackground.isHidden = false
        successDialog.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
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
