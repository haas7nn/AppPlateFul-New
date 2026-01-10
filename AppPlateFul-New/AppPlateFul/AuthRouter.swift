import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthRouter {

    static let shared = AuthRouter()
    private init() {}

    private let db = Firestore.firestore()

    func routeAfterLogin(from vc: UIViewController) {

        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No logged in uid")
            return
        }

        db.collection("users").document(uid).getDocument { snap, error in
            if let error = error {
                print("❌ Firestore error:", error.localizedDescription)
                return
            }

            guard let data = snap?.data() else {
                print("❌ No user doc found at users/\(uid)")
                return
            }

            let role = (data["role"] as? String ?? "").lowercased()
            let status = (data["status"] as? String ?? "active").lowercased()

            guard status == "active" else {
                print("❌ User inactive")
                return
            }

            DispatchQueue.main.async {
                switch role {
                case "admin":
                    vc.performSegue(withIdentifier: "goAdmin", sender: nil)
                case "ngo":
                    vc.performSegue(withIdentifier: "goNGO", sender: nil)
                default:
                    vc.performSegue(withIdentifier: "goDonor", sender: nil)
                }
            }
        }
    }
}

