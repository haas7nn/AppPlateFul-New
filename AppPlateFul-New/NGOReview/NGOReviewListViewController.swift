//
//  NGOReviewListViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit
import FirebaseFirestore

// Displays a list of NGOs pending review (approved = false)
class NGOReviewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyStateLabel: UILabel!

    // MARK: - Data
    private var ngoList: [NGOReviewItem] = []
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NGO Review"

        // Adds a close button for both push and modal cases
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )

        // Table view setup
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()

        // Starts Firestore listener for pending NGOs
        listenPending()
    }

    // Removes Firestore listener when controller is deallocated
    deinit {
        listener?.remove()
    }

    // MARK: - Actions
    // Closes the screen depending on how it was presented
    @objc private func closeTapped() {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    // MARK: - Firestore Listener
    // Listens for NGOs where approved is false, ordered by createdAt
    private func listenPending() {
        listener?.remove()

        let q = db.collection("ngo_reviews")
            .whereField("approved", isEqualTo: false)
            .order(by: "createdAt", descending: true)

        listener = q.addSnapshotListener { [weak self] snap, err in
            guard let self = self else { return }

            if let err = err {
                // Handles Firestore query failure (e.g., missing composite index)
                print("Firestore error:", err.localizedDescription)
                self.ngoList = []
                self.reloadUI()
                return
            }

            // Maps documents into NGOReviewItem objects
            self.ngoList = snap?.documents.compactMap { NGOReviewItem(doc: $0) } ?? []
            self.reloadUI()
        }
    }

    // MARK: - UI Updates
    // Refreshes table data and empty state
    private func reloadUI() {
        tableView.reloadData()
        emptyStateLabel.isHidden = !ngoList.isEmpty
        tableView.isScrollEnabled = !ngoList.isEmpty
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ngoList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NGOCell", for: indexPath)
        let ngo = ngoList[indexPath.row]

        // Default content before loading image
        var content = cell.defaultContentConfiguration()
        content.text = ngo.name
        content.secondaryText = ngo.status
        content.secondaryTextProperties.color = .systemOrange
        content.image = UIImage(systemName: "photo")
        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)
        content.imageProperties.cornerRadius = 10
        cell.contentConfiguration = content

        // Loads logo image asynchronously
        ImageLoader.shared.load(ngo.logoURL) { img in
            DispatchQueue.main.async {
                // Updates only if the cell is still visible
                if let cell = tableView.cellForRow(at: indexPath) {
                    var updated = cell.defaultContentConfiguration()
                    updated.text = ngo.name
                    updated.secondaryText = ngo.status
                    updated.secondaryTextProperties.color = .systemOrange
                    updated.image = img ?? UIImage(systemName: "photo")
                    updated.imageProperties.maximumSize = CGSize(width: 50, height: 50)
                    updated.imageProperties.cornerRadius = 10
                    cell.contentConfiguration = updated
                }
            }
        }

        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        openDetail(for: ngoList[indexPath.row])
    }

    // MARK: - Navigation
    // Opens detail screen for selected NGO
    private func openDetail(for ngo: NGOReviewItem) {
        let storyboard = UIStoryboard(name: "NGOReview", bundle: nil)
        let vc = storyboard.instantiateViewController(
            withIdentifier: "NGOReviewDetailViewController"
        ) as! NGOReviewDetailViewController

        vc.ngo = ngo

        // Removes the NGO from the list after approval/rejection
        vc.onDecision = { [weak self] id in
            self?.ngoList.removeAll { $0.id == id }
            self?.reloadUI()
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
