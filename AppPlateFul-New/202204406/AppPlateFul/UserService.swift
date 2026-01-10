import Foundation
import FirebaseAuth
import FirebaseFirestore

enum UserRole: String {
    case ngo, admin, donor
}

final class UserService {
    private let db = Firestore.firestore()

    func createUser(
        email: String,
        password: String,
        username: String,
        role: UserRole,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error { return completion(.failure(error)) }
            guard let uid = result?.user.uid else {
                return completion(.failure(NSError(domain: "NoUID", code: 0)))
            }

            let data: [String: Any] = [
                "username": username,
                "role": role.rawValue,
                "joinDate": FieldValue.serverTimestamp()
            ]

            self.db.collection("users").document(uid).setData(data) { err in
                if let err = err { return completion(.failure(err)) }
                completion(.success(()))
            }
        }
    }
}
