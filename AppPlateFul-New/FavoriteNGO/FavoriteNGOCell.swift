import UIKit

// custom collection view cell used to display an NGO card
final class FavoriteNGOCell: UICollectionViewCell {

    // UI elements connected from the storyboard.
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var starContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var verifiedBadgeView: UIView!

    // called when the button is tapped
    var onLearnMoreTapped: (() -> Void)?

    // stops image loading when cell is reused
    private var imageToken: String?

    override func awakeFromNib() {
        super.awakeFromNib()

        // image attributes
        setupShadow()
        logoImageView.clipsToBounds = true
        logoImageView.contentMode = .scaleAspectFit
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // cancels any ongoing image loading when the cell is reused
        ImageLoader.shared.cancel(imageToken)
        imageToken = nil

        // Shows a placeholder image.
        logoImageView.image = UIImage(named: "ngo_placeholder") ?? UIImage(systemName: "photo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
    }

    // sets ngo image
    func configureImage(imageNameOrURL: String) {

        // Cleans the image reference before using it.
        let v = imageNameOrURL.trimmingCharacters(in: .whitespacesAndNewlines)

        // Placeholder image shown while loading or if the image fails.
        let placeholder = UIImage(named: "ngo_placeholder") ?? UIImage(systemName: "photo")

        // Loads the image from the internet if the value is a URL.
        if v.lowercased().hasPrefix("http://") || v.lowercased().hasPrefix("https://") {
            imageToken = ImageLoader.shared.load(v, into: logoImageView, placeholder: placeholder)
        } else {
            // Loads a local image asset if the value is not a URL.
            ImageLoader.shared.cancel(imageToken)
            imageToken = nil
            logoImageView.image = UIImage(named: v) ?? placeholder
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.clipsToBounds = true
        }
    }

    // Adds rounded corners and a shadow to the cell for visual styling.
    private func setupShadow() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
    }

    // Triggers the callback when the Learn More button is tapped.
    @IBAction func learnMoreTapped(_ sender: UIButton) {
        onLearnMoreTapped?()
    }
}
