import Foundation

enum UserRole: String, Codable {
    case donor
    case ngo
    case admin
}

struct User: Codable {
    let id: String
    
    // Identity
    var displayName: String
    var imageRef: String?
    var role: UserRole
    
    var email: String?
    var phone: String?
    var status: String?
    var joinDate: String?
    var profileImageName: String?
    var isFavorite: Bool?
    
  
}
extension User {

    func toFirestore() -> [String: Any] {
        [
            "displayName": displayName,
            "imageRef": imageRef as Any,
            "role": role.rawValue,
            "email": email as Any,
            "phone": phone as Any,
            "status": status as Any,
            "joinDate": joinDate as Any,
            "profileImageName": profileImageName as Any,
            "isFavorite": isFavorite as Any
        ]
    }

    static func fromFirestore(_ data: [String: Any], id: String) -> User? {
        guard
            let displayName = data["displayName"] as? String,
            let roleRaw = data["role"] as? String,
            let role = UserRole(rawValue: roleRaw)
        else { return nil }

        return User(
            id: id,
            displayName: displayName,
            imageRef: data["imageRef"] as? String,
            role: role,
            email: data["email"] as? String,
            phone: data["phone"] as? String,
            status: data["status"] as? String,
            joinDate: data["joinDate"] as? String,
            profileImageName: data["profileImageName"] as? String,
            isFavorite: data["isFavorite"] as? Bool
        )
    }
}
