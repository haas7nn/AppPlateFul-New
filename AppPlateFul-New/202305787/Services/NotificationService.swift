//
//  DonationService.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 22/12/2025.
//
import Foundation
import FirebaseFirestore

final class NotificationService {

    static let shared = NotificationService()
    private init() {}

    private let db = Firestore.firestore()

    func fetchNotifications(for userId: String, completion: @escaping ([AppNotification]) -> Void) {

        var result: [AppNotification] = []
        let group = DispatchGroup()

        group.enter()
        db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snap, _ in

                let docs = snap?.documents ?? []

                for d in docs {
                    let x = d.data()

                    let title = x["title"] as? String ?? ""
                    let message = x["message"] as? String ?? ""
                    let isAnnouncement = x["isAnnouncement"] as? Bool ?? false
                    let isGlobal = x["isGlobal"] as? Bool ?? false
                    let userId = x["userId"] as? String

                    var createdAt = Date()
                    if let ts = x["createdAt"] as? Timestamp {
                        createdAt = ts.dateValue()
                    }

                    result.append(
                        AppNotification(
                            id: d.documentID,
                            title: title,
                            message: message,
                            isAnnouncement: isAnnouncement,
                            userId: userId,
                            isGlobal: isGlobal,
                            createdAt: createdAt
                        )
                    )
                }

                group.leave()
            }

        group.enter()
        db.collection("notifications")
            .whereField("isGlobal", isEqualTo: true)
            .getDocuments { snap, _ in

                let docs = snap?.documents ?? []

                for d in docs {
                    let x = d.data()

                    let title = x["title"] as? String ?? ""
                    let message = x["message"] as? String ?? ""
                    let isAnnouncement = x["isAnnouncement"] as? Bool ?? true
                    let isGlobal = x["isGlobal"] as? Bool ?? true
                    let userId = x["userId"] as? String

                    var createdAt = Date()
                    if let ts = x["createdAt"] as? Timestamp {
                        createdAt = ts.dateValue()
                    }

                    result.append(
                        AppNotification(
                            id: d.documentID,
                            title: title,
                            message: message,
                            isAnnouncement: isAnnouncement,
                            userId: userId,
                            isGlobal: isGlobal,
                            createdAt: createdAt
                        )
                    )
                }

                group.leave()
            }

        group.notify(queue: .main) {
            completion(result.sorted { $0.createdAt > $1.createdAt })
        }
    }

    func addEventNotification(to userId: String, title: String, message: String) {

        let id = UUID().uuidString

        let data: [String: Any] = [
            "title": title,
            "message": message,
            "isAnnouncement": false,
            "userId": userId,
            "isGlobal": false,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("notifications").document(id).setData(data)
    }

    func addGlobalAnnouncement(title: String, message: String) {

        let id = UUID().uuidString

        let data: [String: Any] = [
            "title": title,
            "message": message,
            "isAnnouncement": true,
            "userId": NSNull(),
            "isGlobal": true,
            "createdAt": Timestamp(date: Date())
        ]

        db.collection("notifications").document(id).setData(data)
    }
}
