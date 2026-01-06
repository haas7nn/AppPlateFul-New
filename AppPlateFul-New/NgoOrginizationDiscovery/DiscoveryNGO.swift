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

    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        let name = data["name"] as? String ?? ""
        if name.isEmpty { return nil }

        let desc = data["desc"] as? String ?? ""
        let fullDescription = data["fullDescription"] as? String ?? ""
        let verified = data["verified"] as? Bool ?? false
        let imageName = data["imageName"] as? String ?? ""
        let phone = data["phone"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let address = data["address"] as? String ?? ""

        let rating: Double
        if let r = data["rating"] as? Double {
            rating = r
        } else if let r = data["rating"] as? Int {
            rating = Double(r)
        } else {
            rating = 0.0
        }

        let reviews: Int
        if let c = data["reviews"] as? Int {
            reviews = c
        } else if let c = data["reviews"] as? Double {
            reviews = Int(c)
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
