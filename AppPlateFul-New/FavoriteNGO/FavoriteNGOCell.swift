import UIKit

final class FavoriteNGOCell: UICollectionViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var starContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!

    var onLearnMoreTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadow()
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
