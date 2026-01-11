// AppPlateFul // 
// 202301686 - Hasan 
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

/// Handles app routing immediately after a successful Firebase login.
///
/// FirebaseAuth only tells us "a user is signed in".
/// This router then checks Firestore to confirm:
/// 1) the user document exists
/// 2) the user is active (not blocked/inactive)
/// 3) the user data can be parsed into the app's User model
///
/// If any of those checks fail, we sign out and send the user back to Authentication.
final class AuthRouter {

    // MARK: - Singleton
    static let shared = AuthRouter()
    private init() {}

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - Routing
    /// Routes the user to the correct flow after login based on Firestore user role.
    ///
    /// - Parameter vc: The current view controller (kept for flexibility; not required here).
    func routeAfterLogin(from vc: UIViewController) {

        // 1) Ensure FirebaseAuth has a logged-in user.
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in uid")
            AppNavigator.shared.navigateToAuth()
            return
        }

        // 2) Read the user's Firestore document to validate status + role.
        db.collection("users").document(uid).getDocument { snap, error in

            // Firestore failure -> go back to auth (safe fallback).
            if let error = error {
                print("Firestore error:", error.localizedDescription)
                DispatchQueue.main.async {
                    AppNavigator.shared.navigateToAuth()
                }
                return
            }

            // If the user doc does not exist, treat as invalid session.
            guard let snap = snap, snap.exists else {
                print("No user doc found at users/\(uid)")
                do { try Auth.auth().signOut() } catch {}
                DispatchQueue.main.async {
                    AppNavigator.shared.navigateToAuth()
                }
                return
            }

            // 3) Confirm the user is active (basic account control).
            let data = snap.data() ?? [:]
            let status = (data["status"] as? String ?? "active").lowercased()

            guard status == "active" else {
                print("User inactive")
                do { try Auth.auth().signOut() } catch {}
                DispatchQueue.main.async {
                    AppNavigator.shared.navigateToAuth()
                }
                return
            }

            // 4) Convert Firestore document into our app's User model.
            // If parsing fails, do not allow access to any role flow.
            guard let user = User.fromFirestore(snap) else {
                print(" Failed to parse user from Firestore")
                do { try Auth.auth().signOut() } catch {}
                DispatchQueue.main.async {
                    AppNavigator.shared.navigateToAuth()
                }
                return
            }

            // 5) Finally route based on role (admin / ngo / donor / etc.)
            DispatchQueue.main.async {
                AppNavigator.shared.navigate(user: user)
            }
        }
    }
}
