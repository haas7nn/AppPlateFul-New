//
//  ReportsAnalyticsViewController.swift
//  AppPlateFul
//
//  Created by Hassan Fardan on 01/01/2026.
//

import UIKit

class ReportsAnalyticsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reports & Analytics"
        view.backgroundColor = UIColor(red: 0.969, green: 0.953, blue: 0.929, alpha: 1)
        setupUI()
    }
    
    func setupUI() {
        // Main panel
        let panel = UIView()
        panel.backgroundColor = UIColor(red: 0.969, green: 0.953, blue: 0.929, alpha: 1)
        panel.layer.cornerRadius = 35
        panel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(panel)
        
        // Cards data
        let cardsData: [(title: String, value: String, subtitle: String)] = [
            ("Total Donations", "1,234", "all time"),
            ("Completed Deliveries", "892", "this month"),
            ("Canceled Donations", "56", "this month"),
            ("Active NGOs", "24", "registered"),
            ("Active Users", "3,456", "online now")
        ]
        
        // Create cards
        var cards: [UIView] = []
        for data in cardsData {
            let card = createCard(title: data.title, value: data.value, subtitle: data.subtitle)
            panel.addSubview(card)
            cards.append(card)
        }
        
        // Button
        let button = UIButton(type: .system)
        button.setTitle("View Detailed Reports", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.backgroundColor = UIColor(red: 0.718, green: 0.784, blue: 0.604, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(viewDetailedReportsTapped), for: .touchUpInside)
        panel.addSubview(button)
        
        // Layout
        NSLayoutConstraint.activate([
            panel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            panel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            panel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            panel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // Row 1
            cards[0].topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            cards[0].leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            cards[0].heightAnchor.constraint(equalToConstant: 130),
            
            cards[1].topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            cards[1].trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            cards[1].leadingAnchor.constraint(equalTo: cards[0].trailingAnchor, constant: 16),
            cards[1].widthAnchor.constraint(equalTo: cards[0].widthAnchor),
            cards[1].heightAnchor.constraint(equalToConstant: 130),
            
            // Row 2
            cards[2].topAnchor.constraint(equalTo: cards[0].bottomAnchor, constant: 16),
            cards[2].leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            cards[2].widthAnchor.constraint(equalTo: cards[0].widthAnchor),
            cards[2].heightAnchor.constraint(equalToConstant: 130),
            
            cards[3].topAnchor.constraint(equalTo: cards[1].bottomAnchor, constant: 16),
            cards[3].trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            cards[3].leadingAnchor.constraint(equalTo: cards[2].trailingAnchor, constant: 16),
            cards[3].widthAnchor.constraint(equalTo: cards[2].widthAnchor),
            cards[3].heightAnchor.constraint(equalToConstant: 130),
            
            // Row 3
            cards[4].topAnchor.constraint(equalTo: cards[2].bottomAnchor, constant: 16),
            cards[4].leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 16),
            cards[4].widthAnchor.constraint(equalTo: cards[0].widthAnchor),
            cards[4].heightAnchor.constraint(equalToConstant: 130),
            
            button.topAnchor.constraint(equalTo: cards[3].bottomAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -16),
            button.leadingAnchor.constraint(equalTo: cards[4].trailingAnchor, constant: 16),
            button.widthAnchor.constraint(equalTo: cards[4].widthAnchor),
            button.heightAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    func createCard(title: String, value: String, subtitle: String) -> UIView {
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
        
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.boldSystemFont(ofSize: 40)
        valueLabel.textColor = UIColor(red: 0.898, green: 0.224, blue: 0.208, alpha: 1)
        valueLabel.textAlignment = .center
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .gray
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        card.addSubview(titleLabel)
        card.addSubview(valueLabel)
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            valueLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor)
        ])
        
        return card
    }
    
    @objc func viewDetailedReportsTapped() {
        let storyboard = UIStoryboard(name: "Reports", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BreakdownViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}
