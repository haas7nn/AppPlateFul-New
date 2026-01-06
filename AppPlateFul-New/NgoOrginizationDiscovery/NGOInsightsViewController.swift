//
//  NGOInsightsViewController.swift
//  AppPlateFul
//

import UIKit

class NGOInsightsViewController: UIViewController {

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

    var ngoId: String = ""          // 🔥 REQUIRED
    var ngoName: String = ""
    var ngoImageName: String = ""
    var ngoRating: Double = 0.0
    var ngoReviews: Int = 0
    var isVerified: Bool = false
    var ngoAddress: String = ""

    var openingHours: String = "8:00AM – 9:00PM"
    var averagePickupTime: String = "40 mins"
    var collectedDonations: String = "99 this month"
    var pickupReliability: String = "96% on-time"
    var communityReview: String = "Safe food handling and fast delivery"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Feedback & Rating"
        configureNavigationBar()
        configureUI()
    }

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

    private func configureUI() {
        if let image = UIImage(named: ngoImageName) {
            logoImageView?.image = image
        } else {
            logoImageView?.image = UIImage(systemName: "building.2.fill")
            logoImageView?.tintColor = .gray
            logoImageView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        }

        orgNameLabel?.text = ngoName.isEmpty ? "Handful Love" : ngoName
        subtitleLabel?.text = "Food Collection Partner"
        ratingsCountLabel?.text = "\(ngoReviews) ratings"
        verifiedBadgeView?.isHidden = !isVerified

        areaValueLabel?.text = extractArea(from: ngoAddress)
        hoursValueLabel?.text = openingHours
        pickupTimeValueLabel?.text = averagePickupTime
        donationsValueLabel?.text = collectedDonations
        reliabilityValueLabel?.text = pickupReliability
        communityReviewValueLabel?.text = communityReview
    }

    private func extractArea(from address: String) -> String {
        if address.isEmpty { return "Hamad Town" }
        let components = address.components(separatedBy: ",")
        return components.first?.trimmingCharacters(in: .whitespaces) ?? "Hamad Town"
    }

    @IBAction func leaveReviewTapped(_ sender: UIButton) {
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
            title: "Thank You! 🎉",
            message: "Your review has been submitted successfully.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
