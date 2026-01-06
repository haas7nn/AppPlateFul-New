import UIKit

final class FAQViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private struct FAQItem {
        let q: String
        let a: String
        var isOpen: Bool
    }

    private var items: [FAQItem] = [
        FAQItem(q: "What is this app about?",
                a: "PlateFul connects donors with verified NGOs to donate food safely and easily.",
                isOpen: false),

        FAQItem(q: "Is there a fee to donate?",
                a: "No. Donating through PlateFul is free.",
                isOpen: false),

        FAQItem(q: "Who can receive the donations?",
                a: "Only verified NGOs and community organizations registered on the app.",
                isOpen: false),

        FAQItem(q: "How do I know my donation reached the right place?",
                a: "You can track donation updates and confirmation inside the app.",
                isOpen: false),

        FAQItem(q: "What types of food can I donate?",
                a: "Packaged items and properly stored fresh food. Avoid expired items.",
                isOpen: false),
        
        FAQItem(q: "How do I donate using PlateFul?",
                        a: "Choose an NGO, enter your donation details, then follow the delivery or pickup instructions.",
                        isOpen: false),

                FAQItem(q: "Can I donate anonymously?",
                        a: "Yes. You can choose to hide your name when submitting a donation.",
                        isOpen: false),

                FAQItem(q: "Can I cancel or edit a donation after submitting?",
                        a: "Yes, as long as the NGO has not confirmed pickup or completion yet.",
                        isOpen: false),

                FAQItem(q: "How are NGOs verified in the app?",
                        a: "Each NGO is screened before being approved, to ensure safety and transparency.",
                        isOpen: false),

                FAQItem(q: "What if I have a problem with a donation?",
                        a: "Use the support/help option in the app to report the issue and contact the team.",
                        isOpen: false)
            ]
    

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "FAQ"

        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.backgroundView = nil

        tableView.dataSource = self
        tableView.delegate = self
        

        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 70
        tableView.rowHeight = UITableView.automaticDimension

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuestionCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AnswerCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: false)

        // Make sure nav bar is visible + clean
        if let nav = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
            nav.navigationBar.standardAppearance = appearance
            nav.navigationBar.scrollEdgeAppearance = appearance
            nav.navigationBar.compactAppearance = appearance
            nav.navigationBar.tintColor = .black
        }
    }
}

extension FAQViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { items.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items[section].isOpen ? 2 : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = items[indexPath.section]

        // Question
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = .clear
            cell.contentView.backgroundColor = .clear

            // Clean old content (reuse safety)
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }

            // Card (LIGHT GREY)
            let card = UIView()
            card.translatesAutoresizingMaskIntoConstraints = false
            card.backgroundColor = UIColor(white: 0.93, alpha: 1.0)   // ✅ light grey
            card.layer.cornerRadius = 12

            // Label
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = item.q
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textColor = UIColor.black
            label.numberOfLines = 0

            // Chevron
            let chevron = UIImageView()
            chevron.translatesAutoresizingMaskIntoConstraints = false
            chevron.tintColor = UIColor(white: 0.45, alpha: 1.0)
            chevron.image = UIImage(systemName: item.isOpen ? "chevron.up" : "chevron.down")

            cell.contentView.addSubview(card)
            card.addSubview(label)
            card.addSubview(chevron)

            NSLayoutConstraint.activate([
                card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
                card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),

                label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                label.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),

                chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                chevron.widthAnchor.constraint(equalToConstant: 18),
                chevron.heightAnchor.constraint(equalToConstant: 18),
            ])

            return cell
        }

        // Answer
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor(white: 0.93, alpha: 1.0)      // ✅ light grey (same)
        card.layer.cornerRadius = 12

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = item.a
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.textAlignment = .center

        cell.contentView.addSubview(card)
        card.addSubview(label)

        NSLayoutConstraint.activate([
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 0),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),

            label.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            label.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            label.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ])

        return cell
    }
}

extension FAQViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row != 0 { return }

        for i in 0..<items.count {
            if i != indexPath.section { items[i].isOpen = false }
        }

        items[indexPath.section].isOpen.toggle()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 10 }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }
}
