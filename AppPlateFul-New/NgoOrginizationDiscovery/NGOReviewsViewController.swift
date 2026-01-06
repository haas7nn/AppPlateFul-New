//
//  NGOReviewsViewController.swift
//  AppPlateFul
//
//  Created by Hassan on 28/12/2025.
//

import UIKit
import FirebaseFirestore

class NGOReviewsViewController: UIViewController,
                                UITableViewDataSource,
                                UITableViewDelegate,
                                AddReviewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var totalReviewsLabel: UILabel!
    @IBOutlet weak var addReviewButton: UIButton!
    @IBOutlet weak var insightsButton: UIButton!

    // MARK: - Firebase
    private let db = Firestore.firestore()
    var ngoId: String = ""          // 🔥 REQUIRED

    // MARK: - NGO Info
    var ngoName: String = ""
    var ngoImageName: String = ""
    var ngoRating: Double = 0.0
    var ngoReviews: Int = 0
    var isVerified: Bool = false
    var ngoAddress: String = ""

    // MARK: - Reviews
    private var reviews: [(name: String, rating: Int, comment: String, date: String)] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reviews"

        setupUI()
        setupTableView()
        setupButtons()
        configureNavigationBar()
        fetchReviews()
    }

    // MARK: - UI
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.969, green: 0.949, blue: 0.929, alpha: 1.0)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 17)
        ]
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    private func setupUI() {
        view.backgroundColor = UIColor(red: 0.969, green: 0.949, blue: 0.929, alpha: 1.0)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
    }

    private func setupButtons() {
        addReviewButton.layer.cornerRadius = 12
        insightsButton.layer.cornerRadius = 12
    }

    // MARK: - Firestore
    private func fetchReviews() {
        guard !ngoId.isEmpty else { return }

        db.collection("ngos_reviews")
            .document(ngoId)
            .collection("reviews")
            .order(by: "createdAt", descending: true)
            .getDocuments { [weak self] snapshot, error in

                if let error = error {
                    print("Firestore error:", error)
                    return
                }

                self?.reviews = snapshot?.documents.map { doc in
                    let data = doc.data()
                    let name = data["name"] as? String ?? ""
                    let rating: Int
                    if let r = data["rating"] as? Int {
                        rating = r
                    } else if let r = data["rating"] as? Double {
                        rating = Int(r)
                    } else {
                        rating = 5
                    }
                    let comment = data["comment"] as? String ?? ""
                    let timestamp = data["createdAt"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()

                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM d, yyyy"

                    return (name, rating, comment, formatter.string(from: date))
                } ?? []

                self?.updateRatingDisplay()
                self?.tableView.reloadData()
            }
    }

    private func updateRatingDisplay() {
        guard !reviews.isEmpty else {
            averageRatingLabel.text = "⭐️ 0.0"
            totalReviewsLabel.text = "No reviews yet"
            return
        }

        let total = reviews.reduce(0) { $0 + $1.rating }
        let avg = Double(total) / Double(reviews.count)

        averageRatingLabel.text = "⭐️ \(String(format: "%.1f", avg))"
        totalReviewsLabel.text = "Based on \(reviews.count) reviews"
    }

    // MARK: - Actions
    @IBAction func addReviewTapped(_ sender: Any) {
        let vc = AddReviewViewController()
        vc.ngoId = ngoId
        vc.ngoName = ngoName
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }

    @IBAction func insightsTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "NgoOrginzationDiscovery", bundle: nil)
        if let insightsVC = storyboard.instantiateViewController(withIdentifier: "NGOInsightsViewController") as? NGOInsightsViewController {
            insightsVC.ngoId = ngoId
            insightsVC.ngoName = ngoName
            insightsVC.ngoImageName = ngoImageName
            insightsVC.ngoRating = ngoRating
            insightsVC.ngoReviews = ngoReviews
            insightsVC.isVerified = isVerified
            insightsVC.ngoAddress = ngoAddress
            navigationController?.pushViewController(insightsVC, animated: true)
        }
    }

    // MARK: - AddReviewDelegate
    func didAddReview(name: String, rating: Int, comment: String) {
        fetchReviews()
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath)
        let review = reviews[indexPath.row]

        cell.backgroundColor = .white
        cell.layer.cornerRadius = 12
        cell.selectionStyle = .none
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let nameLabel = UILabel()
        nameLabel.text = review.name
        nameLabel.font = .boldSystemFont(ofSize: 16)

        let ratingLabel = UILabel()
        ratingLabel.text = String(repeating: "⭐️", count: review.rating)

        let commentLabel = UILabel()
        commentLabel.text = review.comment
        commentLabel.numberOfLines = 0
        commentLabel.font = .systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [nameLabel, ratingLabel, commentLabel])
        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12)
        ])

        return cell
    }
}
