//
//  DonationService.swift
//  AppPlateFul
//
//  Created by Rashed Alsowaidi on 22/12/2025.
//

import Foundation
import FirebaseFirestore

final class DonationService {

    static let shared = DonationService()
    private init() {}

    private let db = Firestore.firestore()

    func fetchAll(completion: @escaping ([Donation]) -> Void) {
        db.collection("donations").getDocuments { snap, _ in
            let docs = snap?.documents ?? []
            let items = docs.compactMap { d -> Donation? in
                let x = d.data()

                let title = x["title"] as? String ?? ""
                let desc = x["description"] as? String ?? ""
                let quantity = x["quantity"] as? String ?? ""
                let imageRef = x["imageRef"] as? String ?? ""
                let donorId = x["donorId"] as? String ?? ""
                let donorName = x["donorName"] as? String ?? ""
                let ngoId = x["ngoId"] as? String
                let statusRaw = x["status"] as? String ?? DonationStatus.pending.rawValue
                let status = DonationStatus(rawValue: statusRaw) ?? .pending

                var expiryDate: Date?
                if let ts = x["expiryDate"] as? Timestamp {
                    expiryDate = ts.dateValue()
                }

                var pickup: PickupSchedule?
                if let p = x["scheduledPickup"] as? [String: Any] {
                    let pid = p["id"] as? String ?? ""
                    let donationId = p["donationId"] as? String ?? d.documentID
                    let timeRange = p["pickupTimeRange"] as? String ?? ""
                    let location = p["pickupLocation"] as? String ?? ""

                    var pickupDate = Date()
                    if let ts = p["pickupDate"] as? Timestamp {
                        pickupDate = ts.dateValue()
                    }

                    pickup = PickupSchedule(
                        id: pid,
                        donationId: donationId,
                        pickupDate: pickupDate,
                        pickupTimeRange: timeRange,
                        pickupLocation: location
                    )
                }

                return Donation(
                    id: d.documentID,
                    title: title,
                    description: desc,
                    quantity: quantity,
                    expiryDate: expiryDate,
                    imageRef: imageRef,
                    donorId: donorId,
                    donorName: donorName,
                    ngoId: ngoId,
                    status: status,
                    scheduledPickup: pickup
                )
            }

            completion(items)
        }
    }

    func fetchByStatus(_ status: DonationStatus, completion: @escaping ([Donation]) -> Void) {
        db.collection("donations")
            .whereField("status", isEqualTo: status.rawValue)
            .getDocuments { snap, _ in

                let docs = snap?.documents ?? []
                let items = docs.compactMap { d -> Donation? in
                    let x = d.data()

                    let title = x["title"] as? String ?? ""
                    let desc = x["description"] as? String ?? ""
                    let quantity = x["quantity"] as? String ?? ""
                    let imageRef = x["imageRef"] as? String ?? ""
                    let donorId = x["donorId"] as? String ?? ""
                    let donorName = x["donorName"] as? String ?? ""
                    let ngoId = x["ngoId"] as? String
                    let statusRaw = x["status"] as? String ?? DonationStatus.pending.rawValue
                    let status = DonationStatus(rawValue: statusRaw) ?? .pending

                    var expiryDate: Date?
                    if let ts = x["expiryDate"] as? Timestamp {
                        expiryDate = ts.dateValue()
                    }

                    var pickup: PickupSchedule?
                    if let p = x["scheduledPickup"] as? [String: Any] {
                        let pid = p["id"] as? String ?? ""
                        let donationId = p["donationId"] as? String ?? d.documentID
                        let timeRange = p["pickupTimeRange"] as? String ?? ""
                        let location = p["pickupLocation"] as? String ?? ""

                        var pickupDate = Date()
                        if let ts = p["pickupDate"] as? Timestamp {
                            pickupDate = ts.dateValue()
                        }

                        pickup = PickupSchedule(
                            id: pid,
                            donationId: donationId,
                            pickupDate: pickupDate,
                            pickupTimeRange: timeRange,
                            pickupLocation: location
                        )
                    }

                    return Donation(
                        id: d.documentID,
                        title: title,
                        description: desc,
                        quantity: quantity,
                        expiryDate: expiryDate,
                        imageRef: imageRef,
                        donorId: donorId,
                        donorName: donorName,
                        ngoId: ngoId,
                        status: status,
                        scheduledPickup: pickup
                    )
                }

                completion(items)
            }
    }

    func createDonation(_ donation: Donation, completion: ((Error?) -> Void)? = nil) {
        db.collection("donations")
            .document(donation.id)
            .setData(donation.toFirestore()) { error in
                completion?(error)
            }
    }

    func updateStatus(donationId: String, status: DonationStatus, completion: ((Error?) -> Void)? = nil) {
        db.collection("donations")
            .document(donationId)
            .updateData(["status": status.rawValue]) { error in
                completion?(error)
            }
    }

    func attachPickupSchedule(donationId: String, pickup: PickupSchedule, completion: ((Error?) -> Void)? = nil) {
        db.collection("donations")
            .document(donationId)
            .updateData([
                "scheduledPickup": pickup.toFirestore(),
                "status": DonationStatus.toBeApproved.rawValue
            ]) { error in
                completion?(error)
            }
    }

    func updatePickupApproval(donationId: String, approved: Bool, completion: ((Error?) -> Void)? = nil) {
        if approved {
            db.collection("donations").document(donationId)
                .updateData(["status": DonationStatus.toBeCollected.rawValue]) { error in
                    completion?(error)
                }
        } else {
            db.collection("donations").document(donationId)
                .updateData([
                    "status": DonationStatus.accepted.rawValue,
                    "scheduledPickup": NSNull()
                ]) { error in
                    completion?(error)
                }
        }
    }
}
