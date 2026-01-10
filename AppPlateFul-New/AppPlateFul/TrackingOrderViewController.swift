import UIKit

final class TrackingOrderViewController: UIViewController {

    @IBOutlet private weak var deliveredView: UIView!
    @IBOutlet private weak var confirmButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        styleUI()
    }

    private func styleUI() {
        style(view: deliveredView,
              radius: 28,
              opacity: 0.25,
              blur: 12)

        style(view: confirmButton,
              radius: 22,
              opacity: 0.15,
              blur: 8)
    }

    private func style(view: UIView, radius: CGFloat, opacity: Float, blur: CGFloat) {
        view.layer.cornerRadius = radius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = blur
        view.layer.masksToBounds = false
    }

    @IBAction private func didTapConfirmDelivery(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Done ✅",
            message: "Delivery confirmed successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
