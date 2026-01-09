import Foundation

struct DonationHistory {
    let imageName: String
    let restaurantName: String
    let currentStatus: String
    let finalStatus: String
    let date: Date
    let itemsWithQuantity: String
    let pickupDate: Date

    // Optional (details only)
    let house: String?
    let road: String?
    let block: String?
    let area: String?

    let mobileNumber: String?
}
