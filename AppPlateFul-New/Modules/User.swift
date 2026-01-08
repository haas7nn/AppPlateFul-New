//
//  User.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import Foundation
import FirebaseFirestore

// MARK: - User Role
enum UserRole: String, Codable, CaseIterable {
    case donor
    case ngo
    case admin
    case student
    case unknown
    
    /// Display-friendly name
    var displayName: String {
        switch self {
        case .donor: return "Donor"
        case .ngo: return "NGO"
        case .admin: return "Admin"
        case .student: return "Student"
        case .unknown: return "Unknown"
        }
    }
}

// MARK: - User Model
struct User: Codable, Identifiable {
    
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
    
    // MARK: - Computed Properties
    
    /// Returns display name or email as fallback
    var name: String {
        return displayName.isEmpty ? (email ?? "Unknown User") : displayName
    }
    
    /// Returns role as readable string
    var roleText: String {
        return role.displayName
    }
    
    /// Check if user is active
    var isActive: Bool {
        return status?.lowercased() == "active"
    }
}

// MARK: - Firestore Mapping
extension User {
    
    /// Creates User from Firestore QueryDocumentSnapshot
    static func fromFirestore(_ document: QueryDocumentSnapshot) -> User {
        let data = document.data()
        return parseFirestoreData(documentID: document.documentID, data: data)
    }
    
    /// Creates User from Firestore DocumentSnapshot
    static func fromFirestore(_ document: DocumentSnapshot) -> User? {
        guard let data = document.data() else { return nil }
        return parseFirestoreData(documentID: document.documentID, data: data)
    }
    
    /// Shared parsing logic
    private static func parseFirestoreData(documentID: String, data: [String: Any]) -> User {
        
        // Parse display name from multiple possible fields
        let name: String
        if let n = data["displayName"] as? String, !n.isEmpty {
            name = n
        } else if let n = data["name"] as? String, !n.isEmpty {
            name = n
        } else if let fn = data["firstName"] as? String {
            let ln = data["lastName"] as? String ?? ""
            name = "\(fn) \(ln)".trimmingCharacters(in: .whitespaces)
        } else {
            name = "Unknown User"
        }
        
        // Parse role
        let role: UserRole
        if let roleString = data["role"] as? String,
           let parsedRole = UserRole(rawValue: roleString.lowercased()) {
            role = parsedRole
        } else {
            role = .unknown
        }
        
        // Parse join date from Timestamp or String
        var joinDate: String? = nil
        if let timestamp = data["createdAt"] as? Timestamp {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            joinDate = formatter.string(from: timestamp.dateValue())
        } else if let jd = data["joinDate"] as? String {
            joinDate = jd
        }
        
        return User(
            id: documentID,
            displayName: name,
            imageRef: data["imageRef"] as? String ?? data["avatarURL"] as? String,
            role: role,
            email: data["email"] as? String,
            phone: data["phone"] as? String ?? data["phoneNumber"] as? String,
            status: data["status"] as? String ?? "Active",
            joinDate: joinDate,
            profileImageName: data["profileImageName"] as? String,
            isFavorite: data["isFavorite"] as? Bool ?? false
        )
    }
    
    /// Converts User to Firestore dictionary
    func toFirestore() -> [String: Any] {
        var dict: [String: Any] = [
            "displayName": displayName,
            "role": role.rawValue
        ]
        
        if let imageRef { dict["imageRef"] = imageRef }
        if let email { dict["email"] = email }
        if let phone { dict["phone"] = phone }
        if let status { dict["status"] = status }
        if let joinDate { dict["joinDate"] = joinDate }
        if let profileImageName { dict["profileImageName"] = profileImageName }
        if let isFavorite { dict["isFavorite"] = isFavorite }
        
        return dict
    }
}

// MARK: - Sample Data
extension User {
    
    /// Sample users for testing/preview
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
            ),
            User(
                id: "3",
                displayName: "Admin User",
                imageRef: nil,
                role: .admin,
                email: "admin@example.com",
                phone: "+973 3678 9012",
                status: "Active",
                joinDate: "Dec 01, 2023",
                profileImageName: "person.circle.fill",
                isFavorite: false
            )
        ]
    }
}
