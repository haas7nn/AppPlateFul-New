//
//  UserListViewController.swift
//  AppPlateFul
//
//  Created by Hassan Fardan
//  202301686
//

import UIKit
import FirebaseFirestore

class UserListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var emptyStateLabel: UILabel!

    private var users: [User] = []
    private var filteredUsers: [User] = []
    private var isSearching = false

    private let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Users"

        setupBackButton()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.tableFooterView = UIView()

        fixTableViewConstraints()
        fetchUsers()
    }

    private func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backNavTapped)
        )
    }

    @objc private func backNavTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }


    private func fixTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

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
    }

    @IBAction func backTapped(_ sender: UIButton) {
        // Case 1: pushed inside an existing navigation stack
        print("backTapped")
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
            return
        }

        // Case 2: presented modally
        if presentingViewController != nil {
            dismiss(animated: true)
            return
        }

        // Case 3: stuck as root -> force AdminDashboard as app root
        let storyboard = UIStoryboard(name: "AdminDashboard", bundle: nil)
        guard let adminRoot = storyboard.instantiateInitialViewController() else {
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.rootViewController = adminRoot
        window.makeKeyAndVisible()

        UIView.transition(
            with: window,
            duration: 0.35,
            options: .transitionCrossDissolve,
            animations: nil
        )
    }

    private func fetchUsers() {
        db.collection("users").getDocuments { [weak self] snap, error in
            guard let self = self else { return }

            if let error = error {
                print("Fetch users error:", error.localizedDescription)
                return
            }

            let docs = snap?.documents ?? []

            self.users = docs.compactMap { User.fromFirestore($0) }
            self.filteredUsers = self.users

            DispatchQueue.main.async {
                self.reloadUI()
            }
        }
    }

    private func reloadUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !filteredUsers.isEmpty
    }
}

// MARK: - UITableView
extension UserListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "UserCell",
            for: indexPath
        ) as? UserTableViewCell else {
            return UITableViewCell()
        }

        let user = filteredUsers[indexPath.row]

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
