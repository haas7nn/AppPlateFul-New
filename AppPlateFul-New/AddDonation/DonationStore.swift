import Foundation

struct Donation: Codable {
    let itemName: String
    let quantity: Int
    let donatedTo: String
    let merchantName: String
    let specialNotes: String
    let date: Date
}

final class DonationStore {
    
    static let shared = DonationStore()
    private let storageKey = "savedDonations"
    
    private init() {}
    
    func load() -> [Donation] {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: storageKey) else {
            return []
        }
        do {
            return try JSONDecoder().decode([Donation].self, from: data)
        } catch {
            print("Failed to decode donations:", error)
            return []
        }
    }
    
    func save(_ donations: [Donation]) {
        do {
            let data = try JSONEncoder().encode(donations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode donations:", error)
        }
    }
    
    func add(_ donation: Donation) {
        var all = load()
        // newest first
        all.insert(donation, at: 0)
        save(all)
    }
}
