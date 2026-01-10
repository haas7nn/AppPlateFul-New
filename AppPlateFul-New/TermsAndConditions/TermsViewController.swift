//
//  TermsViewController.swift
//  AppPlateFul
//

import UIKit

// MARK: - Question Cell
class TermsQuestionCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var chevronBackground: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberBackground: UIView!
    
    func configure(number: Int, title: String, isOpen: Bool) {
        numberLabel.text = "\(number)"
        titleLabel.text = title
        
        let chevronImage = isOpen ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(systemName: chevronImage)
        
        UIView.animate(withDuration: 0.2) {
            if isOpen {
                self.chevronBackground.backgroundColor = UIColor(red: 0.776, green: 0.635, blue: 0.494, alpha: 1.0)
                self.chevronImageView.tintColor = .white
            } else {
                self.chevronBackground.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                self.chevronImageView.tintColor = UIColor(white: 0.5, alpha: 1.0)
            }
        }
    }
}

// MARK: - Answer Cell
class TermsAnswerCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var accentBar: UIView!
    
    func configure(content: String) {
        contentLabel.text = content
    }
}

// MARK: - Terms View Controller
final class TermsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private struct TermsItem {
        let title: String
        let content: String
        var isOpen: Bool
    }

    private var items: [TermsItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    private func setupData() {
        items = [
            TermsItem(
                title: "Acceptance of Terms",
                content: "By accessing or using PlateFul, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our services. Your continued use constitutes acceptance of any updates or modifications.",
                isOpen: false
            ),
            TermsItem(
                title: "User Eligibility",
                content: "You must be at least 18 years old to use PlateFul. By using our platform, you represent that you have the legal capacity to enter into a binding agreement. Organizations must be legally registered to participate as recipients.",
                isOpen: false
            ),
            TermsItem(
                title: "Account Responsibilities",
                content: "You are responsible for maintaining the confidentiality of your account credentials. You agree to notify us immediately of any unauthorized access. All activities under your account are your responsibility. We reserve the right to suspend accounts that violate our terms.",
                isOpen: false
            ),
            TermsItem(
                title: "Food Donation Guidelines",
                content: "All donated food must be safe for consumption and properly stored. Donors must accurately describe food items, including ingredients and expiration dates. PlateFul is not responsible for the quality or safety of donated items. Recipients should inspect all donations before use.",
                isOpen: false
            ),
            TermsItem(
                title: "Prohibited Activities",
                content: "Users may not: sell or commercialize donated food, misrepresent the nature of donations, use the platform for illegal activities, harass other users, or attempt to bypass our verification systems. Violations may result in permanent account termination.",
                isOpen: false
            ),
            TermsItem(
                title: "Intellectual Property",
                content: "All content, trademarks, and materials on PlateFul are owned by us or our licensors. You may not copy, modify, distribute, or create derivative works without our written permission. User-generated content remains yours, but you grant us a license to use it.",
                isOpen: false
            ),
            TermsItem(
                title: "Limitation of Liability",
                content: "PlateFul is provided \"as is\" without warranties of any kind. We are not liable for any damages arising from your use of the platform, including but not limited to food-related illnesses, failed donations, or data loss. Our total liability is limited to the amount paid to us, if any.",
                isOpen: false
            ),
            TermsItem(
                title: "Privacy and Data",
                content: "Your use of PlateFul is also governed by our Privacy Policy. By using our services, you consent to our data practices as described therein. We implement industry-standard security measures to protect your information.",
                isOpen: false
            ),
            TermsItem(
                title: "Dispute Resolution",
                content: "Any disputes arising from these terms shall be resolved through binding arbitration in accordance with the laws of the Kingdom of Bahrain. You agree to waive any right to a jury trial or class action lawsuit.",
                isOpen: false
            ),
            TermsItem(
                title: "Modifications to Terms",
                content: "We reserve the right to modify these terms at any time. Changes will be effective upon posting to the platform. We will notify users of significant changes via email or in-app notification. Your continued use after changes constitutes acceptance.",
                isOpen: false
            ),
            TermsItem(
                title: "Termination",
                content: "We may terminate or suspend your account at our sole discretion, without notice, for conduct that violates these terms or is harmful to other users, us, or third parties. Upon termination, your right to use the platform ceases immediately.",
                isOpen: false
            ),
            TermsItem(
                title: "Contact Information",
                content: "For questions about these Terms and Conditions, please contact us at:\n\n📧 Email: legal@plateful.app\n📍 Address: Manama, Kingdom of Bahrain\n📞 Support available 24/7 through the app",
                isOpen: false
            )
        ]
    }
    
    private func setupUI() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
    }
}

// MARK: - UITableViewDataSource
extension TermsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].isOpen ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsQuestionCell", for: indexPath) as? TermsQuestionCell else {
                return UITableViewCell()
            }
            cell.configure(number: indexPath.section + 1, title: item.title, isOpen: item.isOpen)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TermsAnswerCell", for: indexPath) as? TermsAnswerCell else {
                return UITableViewCell()
            }
            cell.configure(content: item.content)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension TermsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row != 0 { return }

        // Close other sections
        for i in 0..<items.count {
            if i != indexPath.section {
                items[i].isOpen = false
            }
        }

        // Toggle current section
        items[indexPath.section].isOpen.toggle()
        
        // Reload with animation
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 76 : 100
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 4
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}
