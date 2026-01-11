//
//  UserListViewController.swift
//  AppPlateFul
//
//  Created by Hassan Fardan
//  202301686
//

import UIKit
import FirebaseFirestore

/// Admin screen that lists all users stored in Firestore.
/// Supports:
/// - fetching users from "users" collection
/// - showing empty state when there are no results
/// - opening user details
/// - receiving cell button events via a delegate (info + favorite)
final class UserListViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var emptyStateLabel: UILabel!

    // MARK: - Data
    private var users: [User] = []
    private var filteredUsers: [User] = []
    private var isSearching = false

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // This screen uses the standard nav bar (title + back button).
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Users"
        setupBackButton()

        // Table setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()

        // Workaround layout fix (prevents incorrect storyboard constraints)
        fixTableViewConstraints()

        // Load initial data from Firestore
        fetchUsers()
    }

    // MARK: - Navigation
    /// Adds a standard back arrow in the navigation bar.
    private func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backNavTapped)
        )
    }

    /// Handles back navigation safely for both push and modal presentation.
    @objc private func backNavTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Layout Fix
    /// Forces the table view to sit correctly under the custom header area.
    /// This removes conflicting storyboard constraints and applies a consistent layout.
    private func fixTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        // Remove any height/bottom constraints tied to the tableView (common storyboard conflict).
        for constraint in view.constraints {
            if constraint.firstItem === tableView || constraint.secondItem === tableView {
                if constraint.firstAttribute == .height || constraint.firstAttribute == .bottom {
                    view.removeConstraint(constraint)
                }
            }
        }

        NSLayoutConstraint.activate([
            // NOTE: The 120 top constant is used to push the list below the top UI elements.
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }

    /// Optional storyboard back button action (kept to support the screen’s custom UI design).
    @IBAction private func backTapped(_ sender: UIButton) {
        // Case 1: pushed inside an existing navigation stack
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
            return
        }

        // Case 2: presented modally
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }

        // Case 3: fallback — if this VC somehow became root, reset the app root.
        let storyboard = UIStoryboard(name: "AdminDashboard", bundle: nil)
        guard let adminRoot = storyboard.instantiateInitialViewController() else { return }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }

        window.rootViewController = adminRoot
        window.makeKeyAndVisible()

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }

    // MARK: - Firestore Fetch
    /// Loads users once from Firestore (not realtime listener).
    /// After fetching, updates the table and empty state.
    private func fetchUsers() {
        db.collection("users").getDocuments { [weak self] snap, error in
            guard let self else { return }

            if let error = error {
                print("Fetch users error:", error.localizedDescription)
                return
            }

            let docs = snap?.documents ?? []

            // Convert Firestore documents into app User models.
            self.users = docs.compactMap { User.fromFirestore($0) }

            // Default view shows all users.
            self.filteredUsers = self.users

            DispatchQueue.main.async {
                self.reloadUI()
            }
        }
    }

    /// Refreshes the table and shows/hides the empty state label.
    private func reloadUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !filteredUsers.isEmpty
    }
}

// MARK: - UITableViewDataSource / UITableViewDelegate
extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath
        ) as? UserTableViewCell else {
            return UITableViewCell()
        }

        let user = filteredUsers[indexPath.row]

        // Delegate pattern: the cell reports button taps back to this view controller.
        cell.indexPath = indexPath
        cell.delegate = self

        // Configure the UI using data from the User model.
        cell.configure(
            name: user.displayName,
            status: user.status ?? "Active",
            isStarred: user.isFavorite ?? false,
            avatarURL: user.imageRef
        )

        return cell
    }

    /// Opens the user detail screen when a row is tapped.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let storyboard = UIStoryboard(name: "UserManagement", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "UserDetailsViewController"
        ) as! UserDetailsViewController

        vc.user = filteredUsers[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UserCellDelegate
extension UserListViewController: UserCellDelegate {

    /// Info button behaves the same as selecting the row: opens details.
    func didTapInfoButton(at indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]

        let storyboard = UIStoryboard(name: "UserManagement", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "UserDetailsViewController"
        ) as! UserDetailsViewController

        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }

    /// Toggles favorite locally and reloads only the updated row for a fast UI response.
    func didTapStarButton(at indexPath: IndexPath) {
        filteredUsers[indexPath.row].isFavorite?.toggle()
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
