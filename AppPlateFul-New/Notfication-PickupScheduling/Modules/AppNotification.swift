//
//  AppNotification.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 31/12/2025.
//

import Foundation

struct AppNotification: Codable {

    let id: String
    let title: String
    let message: String
    let isAnnouncement: Bool
    let userId: String?
    let isGlobal: Bool
    let createdAt: Date
}


extension AppNotification {

    func toFirestore() -> [String: Any] {
        [
            "title": title,
            "message": message,
            "isAnnouncement": isAnnouncement,
            "userId": userId as Any,
            "isGlobal": isGlobal,
            "createdAt": createdAt
        ]
    }

    static func fromFirestore(_ data: [String: Any], id: String) -> AppNotification? {
        guard
            let title = data["title"] as? String,
            let message = data["message"] as? String,
            let isAnnouncement = data["isAnnouncement"] as? Bool,
            let isGlobal = data["isGlobal"] as? Bool
        else { return nil }

        let userId = data["userId"] as? String
        let createdAt = data["createdAt"] as? Date ?? Date()

        return AppNotification(
            id: id,
            title: title,
            message: message,
            isAnnouncement: isAnnouncement,
            userId: userId,
            isGlobal: isGlobal,
            createdAt: createdAt
        )
    }
}
