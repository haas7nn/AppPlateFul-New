//
//  DonationModels.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// MARK: - Theme Constants
// Centralized colors and styles for donation-related UI
struct DonationTheme {
    static let backgroundColor = UIColor(red: 0.976, green: 0.965, blue: 0.941, alpha: 1)
    static let cardBackground = UIColor(red: 0.957, green: 0.937, blue: 0.91, alpha: 1)
    static let primaryBrown = UIColor(red: 0.776, green: 0.635, blue: 0.494, alpha: 1)
    
    static let textPrimary = UIColor.black
    static let textSecondary = UIColor(red: 0.235, green: 0.235, blue: 0.263, alpha: 1)
    static let textTertiary = UIColor(red: 0.557, green: 0.557, blue: 0.576, alpha: 1)

    static let statusCompleted = UIColor(red: 0.298, green: 0.686, blue: 0.314, alpha: 1)
    static let statusCancelled = UIColor(red: 0.898, green: 0.224, blue: 0.208, alpha: 1)
    static let statusOngoing = UIColor(red: 0.949, green: 0.6, blue: 0.29, alpha: 1)
    static let statusPending = UIColor(red: 1, green: 0.757, blue: 0.027, alpha: 1)
}

// MARK: - Donation Activity Status (UI)
// Represents donation status values and their associated colors
enum DonationActivityStatus: String, CaseIterable {
    case pending = "Pending"
    case ongoing = "Ongoing"
    case completed = "Completed"
    case pickedUp = "Picked Up"
    case cancelled = "Cancelled"

    var color: UIColor {
        switch self {
        case .pending:
            return DonationTheme.statusPending
        case .ongoing:
            return DonationTheme.statusOngoing
        case .completed, .pickedUp:
            return DonationTheme.statusCompleted
        case .cancelled:
            return DonationTheme.statusCancelled
        }
    }
}

// MARK: - Filter Option (UI)
// Used to filter donation list based on status
enum FilterOption: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case completed = "Completed"
    case pickedUp = "Picked Up"
    case cancelled = "Cancelled"

    var status: DonationActivityStatus? {
        switch self {
        case .all:
            return nil
        case .pending:
            return .pending
        case .completed:
            return .completed
        case .pickedUp:
            return .pickedUp
        case .cancelled:
            return .cancelled
        }
    }
}

// MARK: - Donation Item
// Represents a donated item and its quantity
struct DonationItem {
    let name: String
    let quantity: Int

    var displayText: String {
        "\(name) (x\(quantity))"
    }
}

// MARK: - Delivery Address
// Represents pickup or delivery address information
struct DeliveryAddress {
    let house: String
    let road: String
    let block: String
    let city: String
    let mobileNumber: String

    var formattedAddress: String {
        "\(house), \(road), \(block)\n\(city)"
    }
}

// MARK: - Donation Activity Model (UI)
// Model used to display donation activity in the application
final class DonationActivityDonation {
    let id: String
    let ngoName: String
    let ngoLogo: UIImage?
    let items: [DonationItem]
    var status: DonationActivityStatus
    let createdDate: Date
    let pickupDate: Date?
    let address: DeliveryAddress
    var isReported: Bool = false

    init(
        id: String,
        ngoName: String,
        ngoLogo: UIImage?,
        items: [DonationItem],
        status: DonationActivityStatus,
        createdDate: Date,
        pickupDate: Date?,
        address: DeliveryAddress
    ) {
        self.id = id
        self.ngoName = ngoName
        self.ngoLogo = ngoLogo
        self.items = items
        self.status = status
        self.createdDate = createdDate
        self.pickupDate = pickupDate
        self.address = address
    }

    // Combined text for displaying items list
    var itemsDisplayText: String {
        items.map { $0.displayText }.joined(separator: ", ")
    }

    // Formats creation date for UI display
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy HH:mm"
        return formatter.string(from: createdDate)
    }

    // Formats pickup date for UI display
    var formattedPickupDate: String? {
        guard let pickupDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy, HH:mm"
        return formatter.string(from: pickupDate)
    }
}

// MARK: - Data Provider (UI)
// Provides mock donation data and handles UI updates
final class DonationDataProvider {
    static let shared = DonationDataProvider()
    
    private(set) var donations: [DonationActivityDonation] = []

    private init() {
        loadMockData()
    }

    // Loads sample donation data for UI testing
    private func loadMockData() {
        let address1 = DeliveryAddress(
            house: "House 123",
            road: "Road 45",
            block: "Block A",
            city: "Manama, Bahrain",
            mobileNumber: "+973 1234 5678"
        )

        let address2 = DeliveryAddress(
            house: "Villa 78",
            road: "Street 12",
            block: "Block B",
            city: "Riffa, Bahrain",
            mobileNumber: "+973 9876 5432"
        )

        donations = [
            DonationActivityDonation(
                id: "DON001",
                ngoName: "Royal Humanitarian Foundation",
                ngoLogo: UIImage(named: "islamichands"),
                items: [DonationItem(name: "Chicken Shawarma", quantity: 14)],
                status: .completed,
                createdDate: Date(),
                pickupDate: Date().addingTimeInterval(3600),
                address: address1
            ),
            DonationActivityDonation(
                id: "DON002",
                ngoName: "Dental Foundation",
                ngoLogo: UIImage(named: "islamichands"),
                items: [
                    DonationItem(name: "Mixed Grill", quantity: 8),
                    DonationItem(name: "Rice", quantity: 5)
                ],
                status: .ongoing,
                createdDate: Date().addingTimeInterval(-86400),
                pickupDate: nil,
                address: address2
            ),
            DonationActivityDonation(
                id: "DON003",
                ngoName: "RCO Foundation",
                ngoLogo: UIImage(named: "islamichands"),
                items: [DonationItem(name: "Vegetable Biryani", quantity: 20)],
                status: .cancelled,
                createdDate: Date().addingTimeInterval(-172800),
                pickupDate: nil,
                address: address1
            ),
            DonationActivityDonation(
                id: "DON004",
                ngoName: "Hope Foundation",
                ngoLogo: UIImage(named: "islamichands"),
                items: [DonationItem(name: "Fresh Bread", quantity: 50)],
                status: .pending,
                createdDate: Date().addingTimeInterval(-3600),
                pickupDate: Date().addingTimeInterval(7200),
                address: address2
            ),
            DonationActivityDonation(
                id: "DON005",
                ngoName: "Care & Share",
                ngoLogo: UIImage(named: "islamichands"),
                items: [DonationItem(name: "Fruit Basket", quantity: 10)],
                status: .pickedUp,
                createdDate: Date().addingTimeInterval(-259200),
                pickupDate: Date().addingTimeInterval(-172800),
                address: address1
            )
        ]
    }

    // Updates donation status and notifies observers
    func updateDonationStatus(
        donationId: String,
        newStatus: DonationActivityStatus
    ) {
        if let index = donations.firstIndex(where: { $0.id == donationId }) {
            donations[index].status = newStatus
            NotificationCenter.default.post(
                name: .donationStatusUpdated,
                object: donations[index]
            )
        }
    }

    // Marks donation as reported and notifies observers
    func reportDonation(donationId: String) {
        if let index = donations.firstIndex(where: { $0.id == donationId }) {
            donations[index].isReported = true
            NotificationCenter.default.post(
                name: .donationReported,
                object: donations[index]
            )
        }
    }

    // Returns donations filtered by selected option
    func filteredDonations(by filter: FilterOption) -> [DonationActivityDonation] {
        guard let status = filter.status else {
            return donations
        }
        return donations.filter { $0.status == status }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let donationStatusUpdated =
        Notification.Name("donationStatusUpdated")
    static let donationReported =
        Notification.Name("donationReported")
}
