//
//  NGOReviewItem.swift
//  AppPlateFul-New
//
//  202301686 - Hasan
//

import Foundation
import FirebaseFirestore

/// Represents an NGO item shown in the admin review flow.
/// This model is built defensively because Firestore documents may have different key names
/// (older versions, different teammates, or inconsistent data).
struct NGOReviewItem {

    // MARK: - Identity
    /// Firestore document ID (used for approve/reject updates).
    let id: String

    // MARK: - Primary fields (used in list + detail)
    let name: String
    let status: String
    let logoURL: String

    // MARK: - Detail fields
    /// The detail screen expects Strings for display, so we normalize everything into text here.
    let area: String
    let openingHours: String
    let avgPickupTime: String
    let collectedDonations: String
    let pickupReliability: String
    let communityReviews: String

    // MARK: - Meta
    let approved: Bool
    let createdAt: Date?

    // MARK: - Firestore Init
    /// Creates an NGOReviewItem from a Firestore document.
    /// Returns nil if required fields are missing (e.g., empty name).
    init?(doc: QueryDocumentSnapshot) {
        let data = doc.data()
        self.id = doc.documentID

        // Name: accept multiple possible keys to support inconsistent documents.
        let nameValue =
            (data["name"] as? String) ??
            (data["orgName"] as? String) ??
            (data["organizationName"] as? String) ??
            (data["ngoName"] as? String) ??
            ""

        // Status: default to Pending if missing.
        let statusValue =
            (data["status"] as? String) ??
            (data["requestStatus"] as? String) ??
            (data["state"] as? String) ??
            "Pending"

        // Logo URL: accept multiple possible keys.
        let logoValue =
            (data["logoURL"] as? String) ??
            (data["logoUrl"] as? String) ??
            (data["logo"] as? String) ??
            (data["imageURL"] as? String) ??
            (data["imageUrl"] as? String) ??
            (data["logoName"] as? String) ??
            ""

        // Detail fields (display strings)
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

        // Numeric fields sometimes arrive as Int/Double/String, so we normalize to String safely.
        let donationsValue = NGOReviewItem.anyToString(data["collectedDonations"], fallback: "0")
        let reliabilityValue = NGOReviewItem.anyToString(data["pickupReliability"], fallback: "0")
        let reviewsValue = NGOReviewItem.anyToString(data["communityReviews"], fallback: "0")

        // Approval flag (default false for pending documents).
        self.approved = (data["approved"] as? Bool) ?? false

        // createdAt may be missing; when present it usually comes as a Firestore Timestamp.
        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }

        // Trim whitespace so UI doesn't show accidental spaces/newlines.
        self.name = nameValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.status = statusValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.logoURL = logoValue.trimmingCharacters(in: .whitespacesAndNewlines)

        self.area = areaValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.openingHours = hoursValue.trimmingCharacters(in: .whitespacesAndNewlines)
        self.avgPickupTime = pickupValue.trimmingCharacters(in: .whitespacesAndNewlines)

        self.collectedDonations = donationsValue
        self.pickupReliability = reliabilityValue
        self.communityReviews = reviewsValue

        // Required field validation: we don't want empty/invalid items in the admin list.
        if self.name.isEmpty { return nil }
    }

    // MARK: - Type Normalization
    /// Converts Firestore values (String / Int / Double) into a display-friendly string.
    /// This prevents crashes and avoids scattered parsing logic in view controllers.
    private static func anyToString(_ value: Any?, fallback: String) -> String {
        if let s = value as? String { return s }
        if let i = value as? Int { return "\(i)" }
        if let d = value as? Double {
            if d.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(d))" }
            return String(format: "%.1f", d)
        }
        return fallback
    }

    // MARK: - Firestore Export
    /// Converts this model into Firestore-ready data.
    /// Used when moving an item to another collection (e.g., "ngo_rejected").
    /// NOTE: Signature matches the detail controller call exactly.
    func toFirestoreData(approved: Bool, status: String) -> [String: Any] {
        var data: [String: Any] = [
            "name": name,
            "status": status,
            "logoURL": logoURL,
            "approved": approved,
            "area": area,
            "openingHours": openingHours,
            "avgPickupTime": avgPickupTime,

            // Stored as numbers in Firestore; converted safely from text.
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
