//
//  NGOReviewListViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit
import FirebaseFirestore

/// Admin screen that lists NGOs pending review.
/// Uses a Firestore snapshot listener so the list updates live when new requests arrive.
final class NGOReviewListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyStateLabel: UILabel!

    // MARK: - Data
    private var ngoList: [NGOReviewItem] = []

    // MARK: - Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NGO Review"
        setupNavigation()
        setupTableView()
        listenPending()
    }

    deinit {
        // Important: remove the snapshot listener to avoid leaks and duplicate listeners.
        listener?.remove()
    }

    // MARK: - Setup
    private func setupNavigation() {
        // Close button works for both push navigation and modal presentation.
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Close",
            style: .done,
            target: self,
            action: #selector(closeTapped)
        )
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = 70
        tableView.tableFooterView = UIView()
    }

    // MARK: - Actions
    @objc private func closeTapped() {
        // If pushed inside a navigation stack -> pop.
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
        } else {
            // If presented modally -> dismiss.
            dismiss(animated: true)
        }
    }

    // MARK: - Firestore Listener
    /// Listens for NGOs where `approved == false`, ordered by newest first.
    /// Snapshot listener provides real-time updates without manual refresh.
    private func listenPending() {
        listener?.remove()

        let q = db.collection("ngo_reviews")
            .whereField("approved", isEqualTo: false)
            .order(by: "createdAt", descending: true)

        listener = q.addSnapshotListener { [weak self] snap, err in
            guard let self = self else { return }

            if let err = err {
                // Common cause: Firestore requires a composite index for certain queries.
                print("Firestore error:", err.localizedDescription)
                self.ngoList = []
                self.reloadUI()
                return
            }

            // Convert Firestore docs into app models (invalid docs are ignored by init?).
            self.ngoList = snap?.documents.compactMap { NGOReviewItem(doc: $0) } ?? []
            self.reloadUI()
        }
    }

    // MARK: - UI
    private func reloadUI() {
        tableView.reloadData()

        // Empty state when there are no pending reviews.
        emptyStateLabel.isHidden = !ngoList.isEmpty

        // Optional: disable scrolling when empty to keep UX clean.
        tableView.isScrollEnabled = !ngoList.isEmpty
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ngoList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NGOCell", for: indexPath)
        let ngo = ngoList[indexPath.row]

        // Default content first (fast), then update logo asynchronously.
        var content = cell.defaultContentConfiguration()
        content.text = ngo.name
        content.secondaryText = ngo.status
        content.secondaryTextProperties.color = .systemOrange
        content.image = UIImage(systemName: "photo")
        content.imageProperties.maximumSize = CGSize(width: 50, height: 50)
        content.imageProperties.cornerRadius = 10
        cell.contentConfiguration = content

        // Load logo (cached + async). Update only if the same row is still visible.
        ImageLoader.shared.load(ngo.logoURL) { img in
            DispatchQueue.main.async {
                guard let visibleCell = tableView.cellForRow(at: indexPath) else { return }

                var updated = visibleCell.defaultContentConfiguration()
                updated.text = ngo.name
                updated.secondaryText = ngo.status
                updated.secondaryTextProperties.color = .systemOrange
                updated.image = img ?? UIImage(systemName: "photo")
                updated.imageProperties.maximumSize = CGSize(width: 50, height: 50)
                updated.imageProperties.cornerRadius = 10
                visibleCell.contentConfiguration = updated
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
    /// Opens the detail screen and removes the item locally once a decision is made.
    private func openDetail(for ngo: NGOReviewItem) {
        let storyboard = UIStoryboard(name: "NGOReview", bundle: nil)

        let vc = storyboard.instantiateViewController(
            withIdentifier: "NGOReviewDetailViewController"
        ) as! NGOReviewDetailViewController

        vc.ngo = ngo

        // After approve/reject, remove from this list for immediate UX feedback.
        vc.onDecision = { [weak self] id in
            self?.ngoList.removeAll { $0.id == id }
            self?.reloadUI()
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
