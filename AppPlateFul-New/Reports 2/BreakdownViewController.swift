//
//  BreakdownViewController.swift
//  AppPlateFul
//
//

import UIKit

/// Displays a simple "Breakdown" dashboard using programmatic UI.
/// The screen builds a panel that contains four info cards arranged in a 2x2 grid.
final class BreakdownViewController: UIViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Breakdown"
        view.backgroundColor = UIColor(red: 0.969, green: 0.953, blue: 0.929, alpha: 1)

        setupUI()
    }

    // MARK: - UI Setup
    /// Builds the panel and places 4 cards inside it using Auto Layout constraints.
    private func setupUI() {
        // Main rounded panel container
        let panel = UIView()
        panel.backgroundColor = UIColor(red: 0.969, green: 0.953, blue: 0.929, alpha: 1)
        panel.layer.cornerRadius = 35
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)

        // Static demo data (can be replaced with live analytics later)
        let cardsData: [(title: String, items: String)] = [
            ("Trending Item Types",
             "1. Canned Goods\n2. Fresh Produce\n3. Dairy Products\n4. Baked Goods\n5. Beverages"),
            ("Top 3 NGOs Ranking",
             "1. Food Bank BH\n2. Red Crescent\n3. Charity Fund"),
            ("Top 4 Donating Users",
             "1. Ahmed Ali\n2. Sara Mohammed\n3. Fatima Hassan\n4. Khalid Omar"),
            ("Top 3 Donators",
             "1. Al Jazira Group\n2. Gulf Hotels\n3. Delmon Bakery")
        ]

        // Create the card views
        var cards: [UIView] = []
        for data in cardsData {
            let card = createBreakdownCard(title: data.title, items: data.items)
            panel.addSubview(card)
            cards.append(card)
        }

        // Layout strategy:
        // - Panel pinned to top with fixed height
        // - Cards arranged as 2 rows x 2 columns inside the panel
        // - Cards share equal widths to keep the grid consistent on different devices
        NSLayoutConstraint.activate([
            // Panel constraints
            panel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            panel.heightAnchor.constraint(equalToConstant: 450),

            // Row 1 (Card 0 left, Card 1 right)
            cards[0].topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            cards[0].leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            cards[0].heightAnchor.constraint(equalToConstant: 180),

            cards[1].topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            cards[1].trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            cards[1].leadingAnchor.constraint(equalTo: cards[0].trailingAnchor, constant: 16),
            cards[1].widthAnchor.constraint(equalTo: cards[0].widthAnchor),
            cards[1].heightAnchor.constraint(equalToConstant: 180),

            // Row 2 (Card 2 left, Card 3 right)
            cards[2].topAnchor.constraint(equalTo: cards[0].bottomAnchor, constant: 16),
            cards[2].leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            cards[2].widthAnchor.constraint(equalTo: cards[0].widthAnchor),
            cards[2].heightAnchor.constraint(equalToConstant: 180),

            cards[3].topAnchor.constraint(equalTo: cards[1].bottomAnchor, constant: 16),
            cards[3].trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            cards[3].leadingAnchor.constraint(equalTo: cards[2].trailingAnchor, constant: 16),
            cards[3].widthAnchor.constraint(equalTo: cards[2].widthAnchor),
            cards[3].heightAnchor.constraint(equalToConstant: 180)
        ])
    }

    // MARK: - Card Factory
    /// Creates one rounded white card containing a title and multi-line list text.
    private func createBreakdownCard(title: String, items: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = .black
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let itemsLabel = UILabel()
        itemsLabel.text = items
        itemsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        itemsLabel.textColor = UIColor(red: 0.518, green: 0.557, blue: 0.439, alpha: 1)
        itemsLabel.numberOfLines = 0
        itemsLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(titleLabel)
        card.addSubview(itemsLabel)

        // Card internal layout:
        // title at top center, list below with padding
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),

            itemsLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            itemsLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            itemsLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14)
        ])

        return card
    }
}
