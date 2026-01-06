//
//  User.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import Foundation
import FirebaseFirestore

// Represents supported user roles in the system
enum UserRole: String, Codable {
    case donor
    case ngo
    case admin
    case student
    case unknown
}

// User model used for UI and Firestore mapping
struct User: Codable {
    
    // MARK: - Core
    let id: String
    
    // MARK: - Identity
    var displayName: String
    var imageRef: String?
    var role: UserRole
    
    // MARK: - Contact / Profile
    var email: String?
    var phone: String?
    var status: String?
    var joinDate: String?
    var profileImageName: String?
    var isFavorite: Bool?
    
    // MARK: - Sample Data
    // Used for testing UI without Firestore
    static var sampleUsers: [User] {
        return [
            User(
                id: "1",
                displayName: "Ahmed Ali",
                imageRef: nil,
                role: .donor,
                email: "ahmed@example.com",
                phone: "+973 3456 7890",
                status: "Active",
                joinDate: "Jan 15, 2024",
                profileImageName: "person.circle.fill",
                isFavorite: false
            ),
            User(
                id: "2",
                displayName: "Fatima Hassan",
                imageRef: nil,
                role: .ngo,
                email: "fatima@example.com",
                phone: "+973 3567 8901",
                status: "Active",
                joinDate: "Feb 20, 2024",
                profileImageName: "person.circle.fill",
                isFavorite: true
            )
        ]
    }
    
    // MARK: - Firestore Mapping
    // Creates a User object from Firestore document data
    static func fromFirestore(_ document: QueryDocumentSnapshot) -> User {
        let data = document.data()
        
        // Reads display name from supported fields
        let name: String
        if let n = data["name"] as? String {
            name = n
        } else if let dn = data["displayName"] as? String {
            name = dn
        } else {
            name = "Unknown User"
        }
        
        // Reads role and converts it into UserRole
        let role: UserRole
        if let roleString = data["role"] as? String,
           let parsedRole = UserRole(rawValue: roleString.lowercased()) {
            role = parsedRole
        } else {
            role = .unknown
        }
        
        // Converts createdAt timestamp into readable join date
        var joinDate: String? = nil
        if let timestamp = data["createdAt"] as? Timestamp {
            let date = timestamp.dateValue()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            joinDate = formatter.string(from: date)
        } else if let jd = data["joinDate"] as? String {
            joinDate = jd
        }
        
        return User(
            id: document.documentID,
            displayName: name,
            imageRef: data["imageRef"] as? String,
            role: role,
            email: data["email"] as? String,
            phone: data["phone"] as? String,
            status: data["status"] as? String,
            joinDate: joinDate,
            profileImageName: data["profileImageName"] as? String,
            isFavorite: data["isFavorite"] as? Bool ?? false
        )
    }
}
