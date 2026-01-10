//
//  ProfileService.swift
//  AppPlateFul
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class ProfileService {

    static let shared = ProfileService()

    private let db = Firestore.firestore()
    private let usersCollection = "users"

    private init() {}

    // MARK: - Current User
    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    private var currentUserEmail: String {
        Auth.auth().currentUser?.email ?? ""
    }

    private var currentUserDisplayName: String {
        Auth.auth().currentUser?.displayName ?? ""
    }

    private func userDocRef(_ userId: String) -> DocumentReference {
        db.collection(usersCollection).document(userId)
    }

    // MARK: - Ensure Profile Exists
    func ensureProfileExists(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(ProfileError.notAuthenticated))
            return
        }

        let ref = userDocRef(userId)
        ref.getDocument { [weak self] snap, err in
            if let err = err {
                completion(.failure(err))
                return
            }

            if let snap = snap, snap.exists {
                completion(.success(()))
                return
            }

            guard let self = self else { return }

            let fallbackName = self.currentUserDisplayName.isEmpty ? "User" : self.currentUserDisplayName
            let profile = UserProfile(
                id: userId,
                displayName: fallbackName,
                email: self.currentUserEmail,
                phone: "",
                imageRef: "person.circle.fill",
                profileImageName: "person.circle.fill",
                status: "active",
                createdAt: Date()
            )

            ref.setData(profile.toDictionary()) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Fetch Current User Profile (One-time)
    func fetchUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(ProfileError.notAuthenticated))
            return
        }

        userDocRef(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(ProfileError.userNotFound))
                return
            }

            guard let profile = UserProfile(document: snapshot) else {
                completion(.failure(ProfileError.invalidData))
                return
            }

            completion(.success(profile))
        }
    }

    // MARK: - Fetch Any User Profile by ID
    func fetchUserProfile(userId: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        userDocRef(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(ProfileError.userNotFound))
                return
            }

            guard let profile = UserProfile(document: snapshot) else {
                completion(.failure(ProfileError.invalidData))
                return
            }

            completion(.success(profile))
        }
    }

    // MARK: - Update Profile
    func updateUserProfile(displayName: String, phone: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = currentUserId else {
            completion(.failure(ProfileError.notAuthenticated))
            return
        }

        let updateData: [String: Any] = [
            "displayName": displayName,
            "phone": phone
        ]

        userDocRef(userId).updateData(updateData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = displayName
            changeRequest?.commitChanges { _ in
                completion(.success(()))
            }
        }
    }

    // MARK: - Real-time Listener (Current User)
    func listenForProfileChanges(completion: @escaping (Result<UserProfile, Error>) -> Void) -> ListenerRegistration? {
        guard let userId = currentUserId else {
            completion(.failure(ProfileError.notAuthenticated))
            return nil
        }

        return userDocRef(userId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let snapshot = snapshot, snapshot.exists else {
                completion(.failure(ProfileError.userNotFound))
                return
            }

            guard let profile = UserProfile(document: snapshot) else {
                completion(.failure(ProfileError.invalidData))
                return
            }

            completion(.success(profile))
        }
    }

    // MARK: - Create Profile (Manual)
    func createUserProfile(userId: String, displayName: String, email: String, phone: String = "", completion: @escaping (Result<Void, Error>) -> Void) {
        let profile = UserProfile(
            id: userId,
            displayName: displayName,
            email: email,
            phone: phone,
            imageRef: "person.circle.fill",
            profileImageName: "person.circle.fill",
            status: "active",
            createdAt: Date()
        )

        userDocRef(userId).setData(profile.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

// MARK: - Profile Errors
enum ProfileError: LocalizedError {
    case notAuthenticated
    case userNotFound
    case invalidData
    case updateFailed

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be logged in to access your profile."
        case .userNotFound:
            return "User profile not found."
        case .invalidData:
            return "Invalid profile data."
        case .updateFailed:
            return "Failed to update profile."
        }
    }
}
