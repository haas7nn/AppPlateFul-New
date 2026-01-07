//
//  PickupSchedule.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 22/12/2025.
//

import Foundation

struct PickupSchedule: Codable {
    
    let id: String
    
    let donationId: String
    let pickupDate: Date
    let pickupTimeRange: String
    let pickupLocation: String

   
    
}

extension PickupSchedule {

    func toFirestore() -> [String: Any] {
        return [
            "id": id,
            "donationId": donationId,
            "pickupDate": pickupDate,
            "pickupTimeRange": pickupTimeRange,
            "pickupLocation": pickupLocation
        ]
    }

    static func fromFirestore(_ data: [String: Any]) -> PickupSchedule? {
        guard
            let id = data["id"] as? String,
            let donationId = data["donationId"] as? String,
            let pickupDate = data["pickupDate"] as? Date,
            let pickupTimeRange = data["pickupTimeRange"] as? String,
            let pickupLocation = data["pickupLocation"] as? String
        else {
            return nil
        }

        return PickupSchedule(
            id: id,
            donationId: donationId,
            pickupDate: pickupDate,
            pickupTimeRange: pickupTimeRange,
            pickupLocation: pickupLocation
        )
    }
}
