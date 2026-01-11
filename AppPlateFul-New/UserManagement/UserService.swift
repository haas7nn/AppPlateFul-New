//
//  UserService.swift
//  AppPlateFul
//

import Foundation
import FirebaseFirestore

/// Central service responsible for all user-related Firestore operations.
///
/// This class abstracts Firestore logic away from view controllers,
/// keeping controllers clean and focused on UI + navigation.
final class UserService {

    // MARK: - Singleton
    /// Shared instance used across the app.
    static let shared = UserService()

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // Prevent external initialization
    private init() {}

    // MARK: - Fetch All Users
    /// Fetches all users from the "users" collection.
    /// - Parameter completion: Returns a list of User models or an error.
    func fetchAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {

        db.collection("users").getDocuments { snapshot, error in

            // Handle Firestore error
            if let error = error {
                print("❌ Error fetching users:", error.localizedDescription)
                completion(.failure(error))
                return
            }

            // No documents found (empty collection)
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }

            // Convert Firestore documents into User models
            let users = documents.compactMap { User.fromFirestore($0) }

            print("✅ Loaded \(users.count) users")
            completion(.success(users))
        }
    }

    // MARK: - Fetch Users by Status
    /// Fetches users filtered by a specific status value.
    /// Example: "Active", "Suspended"
    func fetchUsers(byStatus status: String,
                    completion: @escaping (Result<[User], Error>) -> Void) {

        db.collection("users")
            .whereField("status", isEqualTo: status)
            .getDocuments { snapshot, error in

                if let error = error {
                    completion(.failure(error))
                    return
                }

                let users =
                    snapshot?.documents.compactMap { User.fromFirestore($0) } ?? []

                completion(.success(users))
            }
    }

    // MARK: - Update Favorite Status
    /// Updates the "isFavorite" flag for a specific user.
    /// Used when admin marks/unmarks a user as favorite.
    func updateFavorite(userId: String,
                        isFavorite: Bool,
                        completion: @escaping (Bool) -> Void) {

        db.collection("users")
            .document(userId)
            .updateData([
                "isFavorite": isFavorite
            ]) { error in
                completion(error == nil)
            }
    }

    // MARK: - Fetch User Image
    /// Fetches only the image reference (URL or asset name) for a user.
    /// Used to avoid downloading the full user object when unnecessary.
    func fetchUserImage(userId: String,
                        completion: @escaping (String?) -> Void) {

        db.collection("users")
            .document(userId)
            .getDocument { snap, _ in
                let imageRef = snap?.data()?["imageRef"] as? String
                completion(imageRef)
            }
    }

    // MARK: - Fetch Single User
    /// Fetches a single user by document ID.
    func fetchUser(by id: String,
                   completion: @escaping (User?) -> Void) {

        db.collection("users")
            .document(id)
            .getDocument { snapshot, _ in
                guard let snapshot,
                      let user = User.fromFirestore(snapshot) else {
                    completion(nil)
                    return
                }
                completion(user)
            }
    }
}
