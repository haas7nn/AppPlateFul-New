//
//  NGOCardCell.swift
//  AppPlateFul
//

import UIKit

protocol NGOCardCellDelegate: AnyObject {
    func didTapLearnMore(at cell: NGOCardCell)
}

class NGOCardCell: UICollectionViewCell {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var verifiedBadgeView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!

    weak var delegate: NGOCardCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        // Card style/layout design
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true

        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        layer.masksToBounds = false

        
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        logoImageView.backgroundColor = .white
        logoImageView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        
        learnMoreButton.addTarget(self, action: #selector(learnMoreTapped), for: .touchUpInside)
    }

    //handled learn more btn with animation
    @objc private func learnMoreTapped() {
        UIView.animate(withDuration: 0.1, animations: {
            self.learnMoreButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.learnMoreButton.transform = .identity
            }
        }

        //notifies delegate that btn was tapped
        delegate?.didTapLearnMore(at: self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Makes shadow follow rounded corners correctly
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        logoImageView.image = nil
        nameLabel.text = nil
        descriptionLabel.text = nil
        verifiedBadgeView.isHidden = true
    }
}
