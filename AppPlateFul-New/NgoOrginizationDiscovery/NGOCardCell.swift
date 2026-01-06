//
//  NGOCardCell.swift
//  AppPlateFul
//
//  Created by Hassan on 28/12/2025.
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
        learnMoreButton.addTarget(self, action: #selector(learnMoreTapped), for: .touchUpInside)
    }
    
    @objc private func learnMoreTapped() {
        delegate?.didTapLearnMore(at: self)
    }
}
