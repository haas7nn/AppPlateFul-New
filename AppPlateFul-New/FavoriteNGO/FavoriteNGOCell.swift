import UIKit

final class FavoriteNGOCell: UICollectionViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var starContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var verifiedBadgeView: UIView!
    
    var onLearnMoreTapped: (() -> Void)?

    private var imageToken: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadow()

        logoImageView.clipsToBounds = true
        logoImageView.contentMode = .scaleAspectFit
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ImageLoader.shared.cancel(imageToken)
        imageToken = nil

        logoImageView.image = UIImage(named: "ngo_placeholder") ?? UIImage(systemName: "photo")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
    }

    func configureImage(imageNameOrURL: String) {
        let v = imageNameOrURL.trimmingCharacters(in: .whitespacesAndNewlines)

        let placeholder = UIImage(named: "ngo_placeholder") ?? UIImage(systemName: "photo")

        if v.lowercased().hasPrefix("http://") || v.lowercased().hasPrefix("https://") {
            imageToken = ImageLoader.shared.load(v, into: logoImageView, placeholder: placeholder)
        } else {
            ImageLoader.shared.cancel(imageToken)
            imageToken = nil
            logoImageView.image = UIImage(named: v) ?? placeholder
            logoImageView.contentMode = .scaleAspectFit
            logoImageView.clipsToBounds = true
        }
    }

    private func setupShadow() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.masksToBounds = false
    }

    @IBAction func learnMoreTapped(_ sender: UIButton) {
        onLearnMoreTapped?()
    }
}
