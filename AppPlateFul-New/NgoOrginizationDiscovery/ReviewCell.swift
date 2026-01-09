//
//  ReviewCell.swift
//  AppPlateFul
//

import UIKit

class ReviewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = UIColor(red: 0.129, green: 0.129, blue: 0.129, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Colors
    private let avatarColors: [(bg: UIColor, text: UIColor)] = [
        (UIColor(red: 0.204, green: 0.780, blue: 0.349, alpha: 0.2), UIColor(red: 0.204, green: 0.780, blue: 0.349, alpha: 1)),
        (UIColor(red: 0.0, green: 0.478, blue: 1, alpha: 0.2), UIColor(red: 0.0, green: 0.478, blue: 1, alpha: 1)),
        (UIColor(red: 0.584, green: 0.239, blue: 0.878, alpha: 0.2), UIColor(red: 0.584, green: 0.239, blue: 0.878, alpha: 1)),
        (UIColor(red: 1, green: 0.584, blue: 0, alpha: 0.2), UIColor(red: 1, green: 0.584, blue: 0, alpha: 1)),
        (UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 0.2), UIColor(red: 1, green: 0.231, blue: 0.188, alpha: 1))
    ]
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        containerView.addSubview(nameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(starsLabel)
        containerView.addSubview(commentLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            avatarView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            avatarView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            
            dateLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            starsLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            starsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            commentLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            commentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            commentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            commentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configure
    func configure(name: String, rating: Int, comment: String, date: String) {
        nameLabel.text = name
        commentLabel.text = comment
        dateLabel.text = date
        
        // Stars
        var stars = ""
        for i in 1...5 {
            stars += i <= rating ? "⭐️" : "☆"
        }
        starsLabel.text = stars
        
        // Avatar
        let initial = String(name.prefix(1)).uppercased()
        avatarLabel.text = initial
        
        let colorIndex = abs(name.hashValue) % avatarColors.count
        avatarView.backgroundColor = avatarColors[colorIndex].bg
        avatarLabel.textColor = avatarColors[colorIndex].text
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        commentLabel.text = nil
        dateLabel.text = nil
        starsLabel.text = nil
        avatarLabel.text = nil
    }
}
