//
//  NGOInsightsViewController.swift
//  AppPlateFul
//

import UIKit
import FirebaseFirestore

final class NGOInsightsViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var orgNameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var ratingsCountLabel: UILabel!
    @IBOutlet weak var verifiedBadgeView: UIView!
    @IBOutlet weak var areaValueLabel: UILabel!
    @IBOutlet weak var hoursValueLabel: UILabel!
    @IBOutlet weak var pickupTimeValueLabel: UILabel!
    @IBOutlet weak var donationsValueLabel: UILabel!
    @IBOutlet weak var reliabilityValueLabel: UILabel!
    @IBOutlet weak var communityReviewValueLabel: UILabel!
    @IBOutlet weak var leaveReviewButton: UIButton!

    // Passed in from previous screen
    var ngoId: String = ""
    var ngoName: String = ""
    var ngoImageName: String = ""   // Asset OR URL
    var ngoRating: Double = 0.0
    var ngoReviews: Int = 0
    var isVerified: Bool = false
    var ngoAddress: String = ""

    // Firestore-driven (fallback defaults)
    var openingHours: String = "8:00AM – 9:00PM"
    var averagePickupTime: String = "40 mins"
    var collectedDonations: String = "99 this month"
    var pickupReliability: String = "96% on-time"
    var communityReview: String = "Safe food handling and fast delivery"

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Feedback & Rating"
        configureNavigationBar()

        communityReviewValueLabel.numberOfLines = 0

        // show passed values fast
        applyUI()

        // then load real values
        fetchInsightsIfPossible()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // ✅ hide tab bar on this screen
        tabBarController?.tabBar.isHidden = true

        // refresh when coming back
        fetchInsightsIfPossible()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // ✅ show tab bar again when leaving
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Nav Bar
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.969, green: 0.957, blue: 0.949, alpha: 1.0)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1.0),
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    // MARK: - Firestore
    private func fetchInsightsIfPossible() {
        let id = ngoId.trimmingCharacters(in: .whitespacesAndNewlines)
        if id.isEmpty { return }

        db.collection("ngo_reviews")
            .document(id)
            .getDocument { [weak self] snap, error in
                guard let self else { return }

                if let error = error {
                    print("NGOInsights fetch error:", error.localizedDescription)
                    return
                }

                guard let data = snap?.data() else { return }

                // name
                if let v = data["name"] as? String, !v.isEmpty {
                    self.ngoName = self.decodeHTML(v)
                }

                // logo
                let logo = (data["logoURL"] as? String) ?? (data["logoName"] as? String) ?? ""
                if !logo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.ngoImageName = logo
                }

                // rating
                if let r = data["rating"] as? Double { self.ngoRating = r }
                else if let r = data["rating"] as? Int { self.ngoRating = Double(r) }
                else if let r = data["rating"] as? String, let rr = Double(r) { self.ngoRating = rr }

                // ratingsCount (your Firestore uses ratingsCount)
                if let c = data["ratingsCount"] as? Int { self.ngoReviews = c }
                else if let c = data["ratingsCount"] as? Double { self.ngoReviews = Int(c) }
                else if let c = data["ratingsCount"] as? String, let cc = Int(c) { self.ngoReviews = cc }

                // verified
                if let approved = data["approved"] as? Bool {
                    self.isVerified = approved
                } else if let status = data["status"] as? String {
                    let s = status.lowercased()
                    self.isVerified = (s == "approved" || s == "verified" || s == "active")
                }

                // address/area
                let area = (data["area"] as? String) ?? ""
                let address = (data["address"] as? String) ?? ""
                if !address.isEmpty {
                    self.ngoAddress = self.decodeHTML(address)
                } else if !area.isEmpty {
                    self.ngoAddress = self.decodeHTML(area)
                }

                // insight fields
                if let v = data["openingHours"] as? String, !v.isEmpty {
                    self.openingHours = self.decodeHTML(v)
                }
                if let v = data["avgPickupTime"] as? String, !v.isEmpty {
                    self.averagePickupTime = self.decodeHTML(v)
                }
                if let v = data["collectedDonations"] as? String, !v.isEmpty {
                    self.collectedDonations = self.decodeHTML(v)
                }
                if let v = data["pickupReliability"] as? String, !v.isEmpty {
                    self.pickupReliability = self.decodeHTML(v)
                }
                if let v = data["communityReviews"] as? String, !v.isEmpty {
                    self.communityReview = self.decodeHTML(v)
                }

                DispatchQueue.main.async {
                    self.applyUI()
                }
            }
    }

    // MARK: - UI
    private func applyUI() {
        configureLogo()

        orgNameLabel.text = ngoName.isEmpty ? "Organization Name" : ngoName
        subtitleLabel.text = "Food Collection Partner"
        ratingsCountLabel.text = "\(ngoRating) (\(ngoReviews))"
        verifiedBadgeView.isHidden = !isVerified

        areaValueLabel.text = extractArea(from: ngoAddress)
        hoursValueLabel.text = openingHours
        pickupTimeValueLabel.text = averagePickupTime
        donationsValueLabel.text = collectedDonations
        reliabilityValueLabel.text = pickupReliability
        communityReviewValueLabel.text = communityReview
    }

    private func configureLogo() {
        applyPlaceholderStyle()

        let value = ngoImageName.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty { return }

        if value.lowercased().hasPrefix("http") {
            loadImage(from: value)
            return
        }

        if let img = UIImage(named: value) {
            logoImageView.image = img
            logoImageView.tintColor = nil
            logoImageView.backgroundColor = .clear
            logoImageView.contentMode = .scaleAspectFill
        }
    }

    private func applyPlaceholderStyle() {
        logoImageView.image = UIImage(systemName: "building.2.fill")
        logoImageView.tintColor = .gray
        logoImageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        logoImageView.contentMode = .center
        logoImageView.clipsToBounds = true
        logoImageView.layer.cornerRadius = 12
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            guard let data = data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.logoImageView.image = image
                self.logoImageView.tintColor = nil
                self.logoImageView.backgroundColor = .clear
                self.logoImageView.contentMode = .scaleAspectFill
            }
        }.resume()
    }

    private func extractArea(from address: String) -> String {
        let cleaned = decodeHTML(address).trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.isEmpty { return "Hamad Town" }
        let components = cleaned.components(separatedBy: ",")
        return components.first?.trimmingCharacters(in: .whitespaces) ?? "Hamad Town"
    }

    private func decodeHTML(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return text }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        let decoded = try? NSAttributedString(data: data, options: options, documentAttributes: nil)
        return decoded?.string ?? text
    }

    // MARK: - Actions
    @IBAction func leaveReviewTapped(_ sender: UIButton) {
        // If AddReview is storyboard-based, instantiate it from storyboard instead of AddReviewViewController()
        let addReviewVC = AddReviewViewController()
        addReviewVC.ngoName = ngoName
        addReviewVC.ngoId = ngoId
        addReviewVC.delegate = self
        addReviewVC.modalPresentationStyle = .overFullScreen
        addReviewVC.modalTransitionStyle = .crossDissolve
        present(addReviewVC, animated: true)
    }
}

extension NGOInsightsViewController: AddReviewDelegate {
    func didAddReview(name: String, rating: Int, comment: String) {
        let alert = UIAlertController(
            title: "Thank You!",
            message: "Your review has been submitted successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
