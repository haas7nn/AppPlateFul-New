//
//  UserProfile.swift
//  AppPlateFul
//

import Foundation
import FirebaseFirestore

struct UserProfile {
    let id: String
    var displayName: String
    let email: String
    var phone: String
    let imageRef: String
    let profileImageName: String
    let status: String
    let createdAt: Date

    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }

        id = document.documentID
        displayName = data["displayName"] as? String ?? ""
        email = data["email"] as? String ?? ""
        phone = data["phone"] as? String ?? ""
        imageRef = data["imageRef"] as? String ?? "person.circle.fill"
        profileImageName = data["profileImageName"] as? String ?? "person.circle.fill"
        status = data["status"] as? String ?? "active"

        if let timestamp = data["createdAt"] as? Timestamp {
            createdAt = timestamp.dateValue()
        } else {
            createdAt = Date()
        }
    }

    init(id: String,
         displayName: String,
         email: String,
         phone: String,
         imageRef: String = "person.circle.fill",
         profileImageName: String = "person.circle.fill",
         status: String = "active",
         createdAt: Date = Date()) {

        self.id = id
        self.displayName = displayName
        self.email = email
        self.phone = phone
        self.imageRef = imageRef
        self.profileImageName = profileImageName
        self.status = status
        self.createdAt = createdAt
    }

    func toDictionary() -> [String: Any] {
        [
            "displayName": displayName,
            "email": email,
            "phone": phone,
            "imageRef": imageRef,
            "profileImageName": profileImageName,
            "status": status,
            "createdAt": Timestamp(date: createdAt)
        ]
    }

    var memberSinceFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return "Member since \(formatter.string(from: createdAt))"
    }
}
