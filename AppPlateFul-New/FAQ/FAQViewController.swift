//
//  FAQViewController.swift
//  AppPlateFul
//

import UIKit

// MARK: - FAQQuestionCell
/// Renders the question row in the FAQ list.
/// The chevron indicates whether the section is expanded.
final class FAQQuestionCell: UITableViewCell {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var chevronImageView: UIImageView!
    @IBOutlet private weak var chevronBackground: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var iconBackground: UIView!

    /// Updates the question text and the open/closed chevron style.
    func configure(question: String, isOpen: Bool) {
        questionLabel.text = question

        let chevronName = isOpen ? "chevron.up" : "chevron.down"
        chevronImageView.image = UIImage(systemName: chevronName)

        // Small animation makes the expand/collapse state feel responsive.
        UIView.animate(withDuration: 0.2) {
            if isOpen {
                self.chevronBackground.backgroundColor = UIColor(
                    red: 0.256, green: 0.573, blue: 0.166, alpha: 1.0
                )
                self.chevronImageView.tintColor = .white
            } else {
                self.chevronBackground.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
                self.chevronImageView.tintColor = UIColor(white: 0.5, alpha: 1.0)
            }
        }
    }
}

// MARK: - FAQAnswerCell
/// Renders the answer row when a section is expanded.
final class FAQAnswerCell: UITableViewCell {

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var answerLabel: UILabel!
    @IBOutlet private weak var accentBar: UIView!

    func configure(answer: String) {
        answerLabel.text = answer
    }
}

// MARK: - FAQViewController
/// FAQ screen with expandable sections:
/// - Each FAQ item is one table section
/// - Row 0 is the question
/// - Row 1 (optional) is the answer when expanded
/// Also supports search by matching question or answer text.
final class FAQViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchField: UITextField!

    /// Local model used only by this screen.
    private struct FAQItem {
        let q: String
        let a: String
        var isOpen: Bool
    }

    // MARK: - Data
    private var allItems: [FAQItem] = []
    private var filteredItems: [FAQItem] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Custom back button UI, so default nav bar stays hidden here.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Setup
    private func setupData() {
        // Static FAQ content for the app’s Help/Info section.
        allItems = [
            FAQItem(
                q: "What is PlateFul?",
                a: "PlateFul is a food donation platform that connects generous donors with verified NGOs and community organizations. Our mission is to reduce food waste while helping those in need.",
                isOpen: false
            ),
            FAQItem(
                q: "Is there a fee to donate?",
                a: "No! Donating through PlateFul is completely free. We believe in making food donation accessible to everyone without any barriers.",
                isOpen: false
            ),
            FAQItem(
                q: "How do I create an account?",
                a: "Simply download the app, tap 'Sign Up', and follow the easy registration process. You can sign up using your email or phone number.",
                isOpen: false
            ),
            FAQItem(
                q: "How do I donate using PlateFul?",
                a: "It's simple! Browse verified NGOs, select one, enter your donation details (food type, quantity, expiry), choose pickup or delivery, and submit.",
                isOpen: false
            ),
            FAQItem(
                q: "What types of food can I donate?",
                a: "You can donate packaged foods, properly stored fresh items, cooked meals (within safe time limits), canned goods, and dry provisions. Please avoid expired items.",
                isOpen: false
            ),
            FAQItem(
                q: "Can I donate anonymously?",
                a: "Yes! When submitting a donation, you can toggle the 'Donate Anonymously' option. Your personal details won't be shared with the NGO.",
                isOpen: false
            ),
            FAQItem(
                q: "Can I schedule a donation for later?",
                a: "Yes, you can schedule donations for a future date and time that works best for you and the receiving organization.",
                isOpen: false
            ),
            FAQItem(
                q: "How do I track my donation?",
                a: "Go to 'Donation Activity' in the app to see all your donations. Each donation shows its current status: Pending, Ongoing, Picked Up, or Completed.",
                isOpen: false
            ),
            FAQItem(
                q: "Can I cancel or edit a donation?",
                a: "Yes, you can modify or cancel a donation as long as the NGO hasn't confirmed pickup yet. Go to Donation Activity, select the donation, and tap Edit or Cancel.",
                isOpen: false
            ),
            FAQItem(
                q: "How do I know my donation reached?",
                a: "You'll receive status updates throughout the process. Once completed, you'll get a confirmation with details about how your donation helped.",
                isOpen: false
            ),
            FAQItem(
                q: "Who can receive the donations?",
                a: "Only verified NGOs and registered community organizations can receive donations through PlateFul. This ensures your food goes to legitimate causes.",
                isOpen: false
            ),
            FAQItem(
                q: "How are NGOs verified?",
                a: "Each NGO undergoes a thorough screening process including document verification, background checks, and compliance review before being approved.",
                isOpen: false
            ),
            FAQItem(
                q: "Can I choose which NGO receives my donation?",
                a: "Absolutely! You can browse all verified NGOs, view their profiles, see their causes, and select the one that aligns with your values.",
                isOpen: false
            ),
            FAQItem(
                q: "What if I have a problem with a donation?",
                a: "Use the 'Report' button on any donation or go to Settings > Help & Support to contact our team. We typically respond within 24 hours.",
                isOpen: false
            ),
            FAQItem(
                q: "Is my personal information safe?",
                a: "Yes! We use industry-standard encryption and never share your personal data with third parties without your consent.",
                isOpen: false
            ),
            FAQItem(
                q: "How can I contact support?",
                a: "You can reach us through the app's Help section, email us at support@plateful.app, or call our helpline. We're here to help!",
                isOpen: false
            )
        ]

        filteredItems = allItems
    }

    private func setupUI() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)

        tableView.dataSource = self
        tableView.delegate = self

        // Search updates in real-time as the user types.
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchTextChanged(_:)), for: .editingChanged)
        searchField.returnKeyType = .search
    }

    // MARK: - Actions
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        // Works whether the screen was pushed or presented modally.
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func searchTextChanged(_ textField: UITextField) {
        guard let searchText = textField.text?.lowercased(), !searchText.isEmpty else {
            // Reset results when search is cleared.
            filteredItems = allItems
            tableView.reloadData()
            return
        }

        // Match either question or answer content.
        filteredItems = allItems.filter { item in
            item.q.lowercased().contains(searchText) || item.a.lowercased().contains(searchText)
        }
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension FAQViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        filteredItems.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Expanded sections show two rows: question + answer.
        filteredItems[section].isOpen ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = filteredItems[indexPath.section]

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FAQQuestionCell",
                for: indexPath
            ) as? FAQQuestionCell else {
                return UITableViewCell()
            }

            cell.configure(question: item.q, isOpen: item.isOpen)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FAQAnswerCell",
                for: indexPath
            ) as? FAQAnswerCell else {
                return UITableViewCell()
            }

            cell.configure(answer: item.a)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension FAQViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row == 0 else { return }

        // Only one section is allowed open at a time for a clean accordion UX.
        for i in 0..<filteredItems.count where i != indexPath.section {
            filteredItems[i].isOpen = false
        }

        // Toggle the selected section open/closed.
        filteredItems[indexPath.section].isOpen.toggle()

        // Reloading here keeps the logic simple; animation can be improved later if needed.
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.row == 0 ? 80 : 100
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        4
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}

// MARK: - UITextFieldDelegate
extension FAQViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
