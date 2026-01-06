//
//  UserDetailsViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Displays detailed information about a selected user
class UserDetailsViewController: UIViewController {
    
    // MARK: - Properties
    // Selected user to display
    var user: User?
    
    // MARK: - IBOutlets
    // Optional outlets to prevent runtime crashes
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var phoneLabel: UILabel?
    @IBOutlet weak var roleLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var joinDateLabel: UILabel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Details"
        
        setupUI()
        configureContent()
    }
    
    // MARK: - Setup
    // Configures UI appearance
    private func setupUI() {
        avatarImageView?.layer.cornerRadius = 50
        avatarImageView?.clipsToBounds = true
    }
    
    // Populates UI elements with user data
    private func configureContent() {
        guard let user = user else {
            return
        }
        
        // Assign text values safely
        nameLabel?.text = user.displayName
        emailLabel?.text = user.email ?? "-"
        phoneLabel?.text = user.phone ?? "-"
        roleLabel?.text = user.role.rawValue.uppercased()
        statusLabel?.text = user.status ?? "-"
        joinDateLabel?.text = user.joinDate ?? "-"
        
        // Sets avatar image
        let iconName = user.profileImageName ?? "person.circle.fill"
        avatarImageView?.image = UIImage(systemName: iconName)
        avatarImageView?.tintColor = .systemGray2
    }
}
