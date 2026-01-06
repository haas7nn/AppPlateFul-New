//
//  BreakdownViewController.swift
//  AppPlateFul
//
//  Created by Hassan Fardan on 01/01/2026.
//

import UIKit

class BreakdownViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Breakdown"
        view.backgroundColor = UIColor(red: 0.969, green: 0.953, blue: 0.929, alpha: 1)
        setupUI()
    }
    
    func setupUI() {
        let panel = UIView()
        panel.backgroundColor = UIColor(red: 0.969, green: 0.953, blue: 0.929, alpha: 1)
        panel.layer.cornerRadius = 35
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        
        let cardsData: [(title: String, items: String)] = [
            ("Trending Item Types", "1. Canned Goods\n2. Fresh Produce\n3. Dairy Products\n4. Baked Goods\n5. Beverages"),
            ("Top 3 NGOs Ranking", "1. Food Bank BH\n2. Red Crescent\n3. Charity Fund"),
            ("Top 4 Donating Users", "1. Ahmed Ali\n2. Sara Mohammed\n3. Fatima Hassan\n4. Khalid Omar"),
            ("Top 3 Donators", "1. Al Jazira Group\n2. Gulf Hotels\n3. Delmon Bakery")
        ]
        
        var cards: [UIView] = []
        for data in cardsData {
            let card = createBreakdownCard(title: data.title, items: data.items)
            panel.addSubview(card)
            cards.append(card)
        }
        
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            panel.heightAnchor.constraint(equalToConstant: 450),
            
            // Row 1
            cards[0].topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            cards[0].leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            cards[0].heightAnchor.constraint(equalToConstant: 180),
            
            cards[1].topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            cards[1].trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            cards[1].leadingAnchor.constraint(equalTo: cards[0].trailingAnchor, constant: 16),
            cards[1].widthAnchor.constraint(equalTo: cards[0].widthAnchor),
            cards[1].heightAnchor.constraint(equalToConstant: 180),
            
            // Row 2
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
    
    func createBreakdownCard(title: String, items: String) -> UIView {
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
