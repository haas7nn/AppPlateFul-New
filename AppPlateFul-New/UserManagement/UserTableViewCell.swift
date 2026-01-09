//
//  UserTableViewCell.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Custom table view cell used to display a user with actions (info, favorite)
class UserTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var starButton: UIButton?
    @IBOutlet weak var infoButton: UIButton?

    // MARK: - Delegate / Index
    weak var delegate: UserCellDelegate?
    var indexPath: IndexPath!

    // Stores latest avatar URL to avoid wrong image during reuse
    private var currentAvatarURL: String?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()

        // Attach button actions
        starButton?.addTarget(self, action: #selector(starButtonTapped), for: .touchUpInside)
        infoButton?.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }

    // MARK: - Setup
    // Configures UI appearance for avatar
    private func setupUI() {
        avatarImageView?.layer.cornerRadius = 25
        avatarImageView?.clipsToBounds = true
        avatarImageView?.contentMode = .scaleAspectFill
    }

    // MARK: - Actions
    // Notifies delegate when star button is tapped
    @objc private func starButtonTapped() {
        delegate?.didTapStarButton(at: indexPath)
    }

    // Notifies delegate when info button is tapped
    @objc private func infoButtonTapped() {
        delegate?.didTapInfoButton(at: indexPath)
    }

    // MARK: - Configuration
    // Updates cell UI using provided user details
    func configure(
        name: String,
        status: String,
        isStarred: Bool = false,
        avatarURL: String? = nil
    ) {
        nameLabel?.text = name

        // Clean and display status text
        let cleanStatus = status.trimmingCharacters(in: .whitespacesAndNewlines)
        statusLabel?.text = cleanStatus.isEmpty ? "-" : cleanStatus

        // Status color rules
        switch cleanStatus.lowercased() {
        case "active":
            statusLabel?.textColor = .systemGreen
        case "inactive":
            statusLabel?.textColor = .systemRed
        case "pending":
            statusLabel?.textColor = .systemOrange
        default:
            statusLabel?.textColor = .secondaryLabel
        }

        // Favorite icon UI
        let starImage = isStarred ? "star.fill" : "star"
        starButton?.setImage(UIImage(systemName: starImage), for: .normal)
        starButton?.tintColor = isStarred ? .systemYellow : .systemGray

        // Default avatar icon
        avatarImageView?.image = UIImage(systemName: "person.circle.fill")
        avatarImageView?.tintColor = .systemGray2

        // Load avatar from URL if available
        currentAvatarURL = avatarURL

        if let avatarURL, !avatarURL.isEmpty {
            ImageLoader.shared.load(avatarURL) { [weak self] image in
                guard let self else { return }
                guard self.currentAvatarURL == avatarURL else { return }
                if let image {
                    self.avatarImageView?.image = image
                }
            }
        }
    }
}
