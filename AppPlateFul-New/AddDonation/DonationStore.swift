import Foundation

struct Donation {
    let itemName: String
    let quantity: Int
    let donatedTo: String
    let merchantName: String
    let specialNotes: String
    let date: Date
}

final class DonationStore {
    
    static let shared = DonationStore()
    
    private init() {}
    
    // In‑memory only; cleared when app terminates
    private var donations: [Donation] = []
    
    func load() -> [Donation] {
        return donations
    }
    
    func save(_ donations: [Donation]) {
        self.donations = donations
    }
    
    func add(_ donation: Donation) {
        // newest first
        donations.insert(donation, at: 0)
    }
    
    func clear() {
        donations.removeAll()
    }
}
