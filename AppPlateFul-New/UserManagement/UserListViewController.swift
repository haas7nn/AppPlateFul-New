//
//  UserListViewController.swift
//  AppPlateFul
//
//  Created by Hassan Fardan
//202301686

import UIKit
import FirebaseFirestore

class UserListViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    // MARK: - Data
    private var users: [User] = []
    private var filteredUsers: [User] = []
    private var isSearching = false

    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🟢 ========== UserListViewController viewDidLoad ==========")
        
        title = "Users"

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()
        
        fixTableViewConstraints()

        fetchUsers()
    }

    private func fixTableViewConstraints() {
        print("🔧 Fixing TableView constraints...")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove any existing constraints that might conflict
        for constraint in view.constraints {
            if constraint.firstItem === tableView || constraint.secondItem === tableView {
                if constraint.firstAttribute == .height || constraint.firstAttribute == .bottom {
                    view.removeConstraint(constraint)
                }
            }
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        print("TableView constraints applied")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear - TableView frame: \(tableView.frame)")
        print("TableView numberOfRows: \(tableView.numberOfRows(inSection: 0))")
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Firestore
    private func fetchUsers() {
        print("Fetching users from Firestore...")
        
        db.collection("users").getDocuments { [weak self] snap, error in
            guard let self = self else {
                print(" Self is nil")
                return
            }

            if let error = error {
                print(" Fetch users error: \(error.localizedDescription)")
                return
            }

            let docs = snap?.documents ?? []
            print("Firestore users docs: \(docs.count)")

            // Debug: Print first 3 documents
            for (index, d) in docs.prefix(3).enumerated() {
                print(" Doc \(index + 1): \(d.documentID)")
                print("   name: \(d.data()["name"] ?? "nil")")
                print("   displayName: \(d.data()["displayName"] ?? "nil")")
                print("   email: \(d.data()["email"] ?? "nil")")
                print("   status: \(d.data()["status"] ?? "nil")")
            }

            self.users = docs.map { User.fromFirestore($0) }
            print("Parsed users: \(self.users.count)")
            
            // Debug: Print parsed users
            for (index, user) in self.users.prefix(3).enumerated() {
                print(" User \(index + 1): \(user.displayName) - \(user.status ?? "no status")")
            }

            self.filteredUsers = self.users
            print(" filteredUsers count: \(self.filteredUsers.count)")
            
            DispatchQueue.main.async {
                print(" Reloading UI on main thread...")
                self.reloadUI()
            }
        }
    }

    private func reloadUI() {
        print(" reloadUI called")
        print("   filteredUsers.count: \(filteredUsers.count)")
        
        tableView.reloadData()
        emptyStateLabel.isHidden = !filteredUsers.isEmpty
        
        print("   emptyStateLabel.isHidden: \(emptyStateLabel.isHidden)")
        print("   tableView.numberOfRows: \(tableView.numberOfRows(inSection: 0))")
    }
}

// MARK: - UITableView
extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = filteredUsers.count
        print(" numberOfRowsInSection: \(count)")
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(" cellForRowAt: \(indexPath.row)")

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath
        ) as? UserTableViewCell else {
            print("Failed to dequeue UserTableViewCell!")
            return UITableViewCell()
        }

        let user = filteredUsers[indexPath.row]
        print("   Configuring cell for: \(user.displayName)")

        cell.indexPath = indexPath
        cell.delegate = self

        cell.configure(
            name: user.displayName,
            status: user.status ?? "Active",
            isStarred: user.isFavorite ?? false,
            avatarURL: user.imageRef
        )

        return cell
    }

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

    func didTapInfoButton(at indexPath: IndexPath) {
        let user = filteredUsers[indexPath.row]

        let storyboard = UIStoryboard(name: "UserManagement", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "UserDetailsViewController"
        ) as! UserDetailsViewController

        vc.user = user
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapStarButton(at indexPath: IndexPath) {
        filteredUsers[indexPath.row].isFavorite?.toggle()
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
