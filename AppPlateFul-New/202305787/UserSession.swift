//
//  UserSession.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 04/01/2026.
//

import Foundation
import FirebaseAuth

final class UserSession {


    static let shared = UserSession()
    private init() {}

    // Firebase user UID
    var userId: String? {
        Auth.auth().currentUser?.uid
    }

    var isLoggedIn: Bool {
        return userId != nil
    }
}
