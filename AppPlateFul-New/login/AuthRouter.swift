import UIKit
import FirebaseAuth
import FirebaseFirestore

final class AuthRouter {
    
    static let shared = AuthRouter()
    private init() {}
    
    private let db = Firestore.firestore()
    
    func routeAfterLogin(from vc: UIViewController) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No logged in uid")
            AppNavigator.shared.navigateToAuth()
            return
        }
        
        db.collection("users").document(uid).getDocument { snap, error in
            if let error = error {
                print("Firestore error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    AppNavigator.shared.navigateToAuth()
                }
                return
            }
            
            guard let snap = snap, snap.exists else {
                print("No user doc found at users/\(uid)")
                do { try Auth.auth().signOut() } catch {}
                DispatchQueue.main.async {
                    AppNavigator.shared.navigateToAuth()
                }
                return
            }
            
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
            
            // Build your User model using your existing parser
            guard let user = User.fromFirestore(snap) else {
                print("❌ Failed to parse user from Firestore")
                do { try Auth.auth().signOut() } catch {}
                DispatchQueue.main.async {
                    AppNavigator.shared.navigateToAuth()
                }
                return
            }
            
            DispatchQueue.main.async {
                AppNavigator.shared.navigate(user: user)
            }
        }
    }
}
