//
//  UserService.swift
//  AppPlateFul
//

import Foundation
import FirebaseFirestore

class UserService {
    
    static let shared = UserService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Fetch All Users
    func fetchAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection("users").getDocuments { snapshot, error in
            
            if let error = error {
                print("❌ Error fetching users: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }
            
            let users = documents.map { User.fromFirestore($0) }
            print("✅ Loaded \(users.count) users")
            completion(.success(users))
        }
    }
    
    // MARK: - Fetch Users by Status
    func fetchUsers(byStatus status: String, completion: @escaping (Result<[User], Error>) -> Void) {
        
        db.collection("users")
            .whereField("status", isEqualTo: status)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                let users = snapshot?.documents.map { User.fromFirestore($0) } ?? []
                completion(.success(users))
            }
    }
    
    // MARK: - Update Favorite
    func updateFavorite(userId: String, isFavorite: Bool, completion: @escaping (Bool) -> Void) {
        
        db.collection("users").document(userId).updateData([
            "isFavorite": isFavorite
        ]) { error in
            completion(error == nil)
        }
    }
}
