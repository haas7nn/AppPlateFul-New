//
//  UserService.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 07/01/2026.
//

import Foundation
import FirebaseFirestore

final class UserService {

    static let shared = UserService()
    private init() {}

    private let db = Firestore.firestore()

    func fetchUserImage(userId: String, completion: @escaping (String?) -> Void) {
        db.collection("users").document(userId).getDocument { snap, _ in
            let imageRef = snap?.data()?["imageRef"] as? String
            completion(imageRef)
        }
    }
}
