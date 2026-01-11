//
//  UserTableViewCell.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Custom table view cell that displays a user summary
/// with quick actions (info and favorite).
///
/// The cell itself contains no navigation or business logic.
/// All actions are reported to the parent view controller
/// using the UserCellDelegate protocol.
final class UserTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet private weak var avatarImageView: UIImageView?
    @IBOutlet private weak var nameLabel: UILabel?
    @IBOutlet private weak var statusLabel: UILabel?
    @IBOutlet private weak var starButton: UIButton?
    @IBOutlet private weak var infoButton: UIButton?

    // MARK: - Delegate & Index
    /// Delegate used to notify the parent controller about button taps.
    weak var delegate: UserCellDelegate?

    /// IndexPath of the cell, passed back to the controller when actions occur.
    var indexPath: IndexPath!

    // MARK: - Reuse Safety
    /// Stores the last avatar URL assigned to this cell.
    /// This prevents incorrect images appearing when cells are reused.
    private var currentAvatarURL: String?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()

        // Attach button actions
        starButton?.addTarget(self,
                              action: #selector(starButtonTapped),
                              for: .touchUpInside)

        infoButton?.addTarget(self,
                              action: #selector(infoButtonTapped),
                              for: .touchUpInside)
    }

    // MARK: - UI Setup
    /// Applies basic styling for the avatar image.
    private func setupUI() {
        avatarImageView?.layer.cornerRadius = 25
        avatarImageView?.clipsToBounds = true
        avatarImageView?.contentMode = .scaleAspectFill
    }

    // MARK: - Actions
    /// Notifies the delegate that the favorite (star) button was tapped.
    @objc private func starButtonTapped() {
        delegate?.didTapStarButton(at: indexPath)
    }

    /// Notifies the delegate that the info button was tapped.
    @objc private func infoButtonTapped() {
        delegate?.didTapInfoButton(at: indexPath)
    }

    // MARK: - Configuration
    /// Configures the cell using user data provided by the view controller.
    ///
    /// - Parameters:
    ///   - name: User display name
    ///   - status: User status (Active, Pending, etc.)
    ///   - isStarred: Whether the user is marked as favorite
    ///   - avatarURL: Optional URL string for the user avatar
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

        // Status color rules for quick visual feedback
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

        // Favorite (star) icon state
        let starImageName = isStarred ? "star.fill" : "star"
        starButton?.setImage(UIImage(systemName: starImageName), for: .normal)
        starButton?.tintColor = isStarred ? .systemYellow : .systemGray

        // Default avatar placeholder
        avatarImageView?.image = UIImage(systemName: "person.circle.fill")
        avatarImageView?.tintColor = .systemGray2

        // Store avatar URL to protect against reuse issues
        currentAvatarURL = avatarURL

        // Load avatar image asynchronously if available
        if let avatarURL, !avatarURL.isEmpty {
            ImageLoader.shared.load(avatarURL) { [weak self] image in
                guard let self else { return }
                // Ensure the image still belongs to this cell
                guard self.currentAvatarURL == avatarURL else { return }

                if let image {
                    self.avatarImageView?.image = image
                }
            }
        }
    }
}
