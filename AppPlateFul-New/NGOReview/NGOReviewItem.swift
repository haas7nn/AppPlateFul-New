//
//  NGOReviewItem.swift
//  AppPlateFul-New
//
//  202301686 - Hasan
//

import Foundation
import FirebaseFirestore

struct NGOReviewItem {

    let id: String

    // Used in list + detail
    let name: String
    let status: String
    let logoURL: String

    // Detail screen expects Strings for all these
    let area: String
    let openingHours: String
    let avgPickupTime: String
    let collectedDonations: String
    let pickupReliability: String
    let communityReviews: String

    // Optional meta
    let approved: Bool
    let createdAt: Date?

    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        self.id = doc.documentID

        // name
        let nameValue =
            (data["name"] as? String) ??
            (data["orgName"] as? String) ??
            (data["organizationName"] as? String) ??
            (data["ngoName"] as? String) ??
            ""

        // status
        let statusValue =
            (data["status"] as? String) ??
            (data["requestStatus"] as? String) ??
            (data["state"] as? String) ??
            "Pending"

        // logoURL
        let logoValue =
            (data["logoURL"] as? String) ??
            (data["logoUrl"] as? String) ??
            (data["logo"] as? String) ??
            (data["imageURL"] as? String) ??
            (data["imageUrl"] as? String) ??
            (data["logoName"] as? String) ??
            ""

        // detail strings
        let areaValue =
            (data["area"] as? String) ??
            (data["location"] as? String) ??
            (data["city"] as? String) ??
            ""

        let hoursValue =
            (data["openingHours"] as? String) ??
            (data["hours"] as? String) ??
            (data["workingHours"] as? String) ??
            ""

        let pickupValue =
            (data["avgPickupTime"] as? String) ??
            (data["pickupTime"] as? String) ??
            (data["averagePickupTime"] as? String) ??
            ""

        // numbers -> string (safe)
        let donationsValue = NGOReviewItem.anyToString(data["collectedDonations"], fallback: "0")
        let reliabilityValue = NGOReviewItem.anyToString(data["pickupReliability"], fallback: "0")
        let reviewsValue = NGOReviewItem.anyToString(data["communityReviews"], fallback: "0")

        self.approved = (data["approved"] as? Bool) ?? false

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }

        self.name = nameValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.status = statusValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.logoURL = logoValue.trimmingCharacters(in: .whitespacesAndNewlines)

        self.area = areaValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.openingHours = hoursValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.avgPickupTime = pickupValue.trimmingCharacters(in: .whitespacesAndNewlines)

        self.collectedDonations = donationsValue
        self.pickupReliability = reliabilityValue
        self.communityReviews = reviewsValue

        if self.name.isEmpty { return nil }
    }

    private static func anyToString(_ value: Any?, fallback: String) -> String {
        if let s = value as? String { return s }
        if let i = value as? Int { return "\(i)" }
        if let d = value as? Double {
            if d.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(d))" }
            return String(format: "%.1f", d)
        }
        return fallback
    }

    // ✅ EXACT signature your Detail VC calls
    func toFirestoreData(approved: Bool, status: String) -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "status": status,
            "logoURL": logoURL,
            "approved": approved,
            "area": area,
            "openingHours": openingHours,
            "avgPickupTime": avgPickupTime,
            "collectedDonations": Int(collectedDonations) ?? 0,
            "pickupReliability": Double(pickupReliability) ?? 0.0,
            "communityReviews": Int(communityReviews) ?? 0
        ]

        if let createdAt = createdAt {
            data["createdAt"] = Timestamp(date: createdAt)
        }

        return data
    }
}
