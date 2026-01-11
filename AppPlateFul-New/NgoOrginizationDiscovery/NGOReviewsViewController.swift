//
//  NGOReviewsViewController.swift
//  AppPlateFul
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
    var ngoId: String = ""

    // MARK: - NGO Info
    var ngoName: String = ""
    var ngoImageName: String = ""
    var ngoRating: Double = 0.0
    var ngoReviews: Int = 0
    var isVerified: Bool = false
    var ngoAddress: String = ""

    // MARK: - Reviews
    private var reviews: [(name: String, rating: Int, comment: String, date: String)] = []

    // MARK: - Listener
    private var reviewsListener: ListenerRegistration?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reviews"

        setupUI()
        setupTableView()
        setupButtons()
        configureNavigationBar()
        
        //starts listening for any review changes in firestore
        startListeningForReviews()
    }

    // Hide tab bar ONLY on this screen
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }

    // Bring tab bar back when leaving this screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    deinit {
        reviewsListener?.remove()
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
        tableView.register(ReviewCell.self, forCellReuseIdentifier: "ReviewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
    }

    private func setupButtons() {
        addReviewButton.layer.cornerRadius = 12
        addReviewButton.clipsToBounds = true

        insightsButton.layer.cornerRadius = 12
        insightsButton.clipsToBounds = true
    }

    // listens to firestore ans updates reviews
    private func startListeningForReviews() {
        guard !ngoId.isEmpty else {
            print("startListeningForReviews stopped: ngoId is empty")
            return
        }
        
        //creates listener for ngo_reviews
        reviewsListener = db.collection("ngo_reviews")
            .document(ngoId)
            .collection("reviews")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Firestore error:", error.localizedDescription)
                    return
                }

                let docs = snapshot?.documents ?? []
                print("Fetched reviews count:", docs.count, "for ngoId:", self.ngoId)

                self.reviews = docs.map { doc in
                    let data = doc.data()

                    let name = data["name"] as? String ?? "Anonymous"

                    let rating: Int
                    if let r = data["rating"] as? Int {
                        rating = r
                    } else if let r = data["rating"] as? Double {
                        rating = Int(r)
                    } else {
                        rating = 5
                    }

                    let comment = data["comment"] as? String ?? ""

                    let date: Date
                    if let ts = data["createdAt"] as? Timestamp {
                        date = ts.dateValue()
                    } else {
                        date = Date()
                    }

                    let formatter = RelativeDateTimeFormatter()
                    formatter.unitsStyle = .abbreviated

                    return (name, rating, comment, formatter.localizedString(for: date, relativeTo: Date()))
                }

                DispatchQueue.main.async {
                    self.updateRatingDisplay()
                    self.tableView.reloadData()
                }
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
        totalReviewsLabel.text = "Based on \(reviews.count) review\(reviews.count == 1 ? "" : "s")"
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
    
    //called after a review is added
    func didAddReview(name: String, rating: Int, comment: String) {
        // Real-time listener will automatically update
        showSuccessToast()
    }

    private func showSuccessToast() {
        let toast = UILabel()
        toast.text = "✓ Review added!"
        toast.textColor = .white
        toast.font = .systemFont(ofSize: 15, weight: .medium)
        toast.backgroundColor = UIColor(red: 0.204, green: 0.780, blue: 0.349, alpha: 1)
        toast.textAlignment = .center
        toast.layer.cornerRadius = 20
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toast)

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            toast.widthAnchor.constraint(equalToConstant: 150),
            toast.heightAnchor.constraint(equalToConstant: 40)
        ])

        toast.alpha = 0
        toast.transform = CGAffineTransform(translationX: 0, y: 20)

        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
            toast.transform = .identity
        }

        UIView.animate(withDuration: 0.3, delay: 2.0) {
            toast.alpha = 0
            toast.transform = CGAffineTransform(translationX: 0, y: 20)
        } completion: { _ in
            toast.removeFromSuperview()
        }
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as? ReviewCell else {
            return UITableViewCell()
        }

        let review = reviews[indexPath.row]
        cell.configure(name: review.name, rating: review.rating, comment: review.comment, date: review.date)
        return cell
    }
}
