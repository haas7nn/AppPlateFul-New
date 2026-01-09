import UIKit

final class TermsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet private weak var tableView: UITableView!

    private struct Term {
        let title: String
        let body: String
        var isOpen: Bool
    }

    private var terms: [Term] = [
        Term(title: "1. Acceptance of Terms",
             body: "By using this application, you agree to comply with and be bound by these terms and conditions. If you do not agree to these terms, please do not use this application.",
             isOpen: false),

        Term(title: "2. Use of the service",
             body: "You agree to use this application only for lawful purposes and in a way that does not infringe upon the rights of others or restrict or inhibit anyone else’s use of the application.",
             isOpen: false),

        Term(title: "3. User Account",
             body: "To use the application you may be required to create an account or log in. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.",
             isOpen: false),

        Term(title: "4. Privacy Policy",
             body: "Your use of this application is also governed by our Privacy Policy. Please review our Privacy Policy to understand how we collect and use information.",
             isOpen: false),

        Term(title: "5. Donations Policy",
             body: "Donations must follow the app’s guidelines. We may reject items that do not meet safety, quality, or eligibility requirements.",
             isOpen: false),

        Term(title: "6. Limitation of Liability",
             body: "We do not guarantee error-free or uninterrupted service. Plateful is not liable for any damages resulting from your use of the service.",
             isOpen: false),

        Term(title: "7. Governing Law",
             body: "These terms are governed by the laws of Bahrain. If disputes arise, they will be settled in the courts of Bahrain, and you agree to submit to their authority.",
             isOpen: false),

        Term(title: "8. Changes to Terms",
             body: "Plateful reserves the right to modify or replace these terms at any time. Changes will be effective immediately upon posting. Please check this page periodically for updates.",
             isOpen: false)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Terms & Conditions"
        navigationController?.setNavigationBarHidden(false, animated: false)

        view.backgroundColor = .white

        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self

        tableView.estimatedRowHeight = 140
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Table

    func numberOfSections(in tableView: UITableView) -> Int {
        terms.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        terms[section].isOpen ? 2 : 1
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let id = "TermCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)

        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        // wipe reused content
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let term = terms[indexPath.section]
        let isTitleRow = (indexPath.row == 0)

        // card
        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.layer.cornerRadius = 14
        card.backgroundColor = UIColor(white: 0.93, alpha: 1.0)

        cell.contentView.addSubview(card)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10)
        ])

        if isTitleRow {
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.numberOfLines = 0
            titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            titleLabel.textColor = .black
            titleLabel.text = term.title

            let chevron = UIImageView()
            chevron.translatesAutoresizingMaskIntoConstraints = false
            chevron.tintColor = UIColor(white: 0.45, alpha: 1.0)
            chevron.image = UIImage(systemName: term.isOpen ? "chevron.up" : "chevron.down")

            card.addSubview(titleLabel)
            card.addSubview(chevron)

            NSLayoutConstraint.activate([
                chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                chevron.widthAnchor.constraint(equalToConstant: 18),
                chevron.heightAnchor.constraint(equalToConstant: 18),

                titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
                titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                titleLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            ])
        } else {
            let bodyLabel = UILabel()
            bodyLabel.translatesAutoresizingMaskIntoConstraints = false
            bodyLabel.numberOfLines = 0
            bodyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            bodyLabel.textColor = UIColor(white: 0.25, alpha: 1.0)
            bodyLabel.text = term.body

            card.addSubview(bodyLabel)

            NSLayoutConstraint.activate([
                bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                bodyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
                bodyLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                bodyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            ])
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 { return }

        for i in 0..<terms.count {
            if i != indexPath.section { terms[i].isOpen = false }
        }
        terms[indexPath.section].isOpen.toggle()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        6
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}
