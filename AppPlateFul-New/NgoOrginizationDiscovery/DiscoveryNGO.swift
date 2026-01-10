//
//  DiscoveryNGO.swift
//  AppPlateFul
//

import Foundation
import FirebaseFirestore

struct DiscoveryNGO {

    let id: String
    let name: String
    let desc: String
    let fullDescription: String
    let verified: Bool
    let imageName: String
    let rating: Double
    let reviews: Int
    let phone: String
    let email: String
    let address: String

    init(
        id: String,
        name: String,
        desc: String,
        fullDescription: String,
        verified: Bool,
        imageName: String,
        rating: Double,
        reviews: Int,
        phone: String,
        email: String,
        address: String
    ) {
        self.id = id
        self.name = name
        self.desc = desc
        self.fullDescription = fullDescription
        self.verified = verified
        self.imageName = imageName
        self.rating = rating
        self.reviews = reviews
        self.phone = phone
        self.email = email
        self.address = address
    }

    // Used when fetching with getDocuments()
    init?(doc: QueryDocumentSnapshot) {
        self.init(doc: doc as DocumentSnapshot)
    }

    // Used when fetching a single document
    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        // Name (supports multiple keys)
        let name = data["name"] as? String
            ?? data["orgName"] as? String
            ?? data["organizationName"] as? String
            ?? ""
        if name.isEmpty { return nil }

        // Description (supports multiple keys)
        let desc = data["desc"] as? String
            ?? data["tagline"] as? String
            ?? data["description"] as? String
            ?? data["about"] as? String
            ?? data["bio"] as? String
            ?? ""

        // Full description (supports multiple keys)
        let fullDescription = data["fullDescription"] as? String
            ?? data["details"] as? String
            ?? data["fullDetails"] as? String
            ?? desc

        // Verified (supports multiple keys + types)
        let verified: Bool = {
            if let b = data["verified"] as? Bool { return b }
            if let b = data["isVerified"] as? Bool { return b }
            if let b = data["approved"] as? Bool { return b }

            if let n = data["verified"] as? Int { return n != 0 }
            if let n = data["isVerified"] as? Int { return n != 0 }
            if let n = data["approved"] as? Int { return n != 0 }

            if let s = data["verified"] as? String {
                let v = s.lowercased()
                return v == "true" || v == "1" || v == "yes"
            }
            if let s = data["approved"] as? String {
                let v = s.lowercased()
                return v == "true" || v == "1" || v == "yes"
            }

            if let status = data["status"] as? String {
                let v = status.lowercased()
                return v == "verified" || v == "approved" || v == "active"
            }

            return false
        }()

       
        let imageName = data["logoURL"] as? String
            ?? data["imageName"] as? String
            ?? data["logoName"] as? String
            ?? data["image"] as? String
            ?? ""


        // Contact
        let phone = data["phone"] as? String ?? data["phoneNumber"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let address = data["address"] as? String ?? data["location"] as? String ?? ""

        // Rating
        let rating: Double
        if let r = data["rating"] as? Double {
            rating = r
        } else if let r = data["rating"] as? Int {
            rating = Double(r)
        } else if let r = data["rating"] as? String, let rr = Double(r) {
            rating = rr
        } else {
            rating = 0.0
        }

        // Reviews count
        let reviews: Int
        if let c = data["reviews"] as? Int {
            reviews = c
        } else if let c = data["reviews"] as? Double {
            reviews = Int(c)
        } else if let c = data["reviews"] as? String, let cc = Int(c) {
            reviews = cc
        } else if let c = data["reviewsCount"] as? Int {
            reviews = c
        } else {
            reviews = 0
        }

        self.init(
            id: doc.documentID,
            name: name,
            desc: desc,
            fullDescription: fullDescription,
            verified: verified,
            imageName: imageName,
            rating: rating,
            reviews: reviews,
            phone: phone,
            email: email,
            address: address
        )
    }
}
