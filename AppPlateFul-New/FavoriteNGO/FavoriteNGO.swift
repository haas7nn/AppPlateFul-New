import Foundation
import FirebaseFirestore

struct FavoriteNGO {
    let id: String
    let name: String
    let desc: String
    let fullDescription: String

    let logoURL: String
    let logoAssetName: String

    let rating: Double
    let reviews: Int
    let phone: String
    let email: String
    let address: String

    // Backward compatible (your VC/details uses ngo.imageName)
    var imageName: String {
        return !logoURL.isEmpty ? logoURL : logoAssetName
    }

    init?(doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        func clean(_ s: String?) -> String {
            (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        let name =
            clean(data["name"] as? String) != "" ? clean(data["name"] as? String) :
            clean(data["ngoName"] as? String) != "" ? clean(data["ngoName"] as? String) :
            clean(data["orgName"] as? String) != "" ? clean(data["orgName"] as? String) :
            clean(data["organizationName"] as? String)

        if name.isEmpty { return nil }

        let desc =
            clean(data["desc"] as? String) != "" ? clean(data["desc"] as? String) :
            clean(data["tagline"] as? String) != "" ? clean(data["tagline"] as? String) :
            clean(data["description"] as? String) != "" ? clean(data["description"] as? String) :
            clean(data["about"] as? String)

        let fullDescription =
            clean(data["fullDescription"] as? String) != "" ? clean(data["fullDescription"] as? String) :
            clean(data["details"] as? String) != "" ? clean(data["details"] as? String) :
            clean(data["fullDetails"] as? String) != "" ? clean(data["fullDetails"] as? String) :
            desc

        let rawImage =
            clean(data["logoURL"] as? String) != "" ? clean(data["logoURL"] as? String) :
            clean(data["imageName"] as? String) != "" ? clean(data["imageName"] as? String) :
            clean(data["logoName"] as? String) != "" ? clean(data["logoName"] as? String) :
            clean(data["image"] as? String)

        let isURL = rawImage.lowercased().hasPrefix("http://") || rawImage.lowercased().hasPrefix("https://")
        self.logoURL = isURL ? rawImage : ""
        self.logoAssetName = isURL ? "" : rawImage

        let phone =
            clean(data["phone"] as? String) != "" ? clean(data["phone"] as? String) :
            clean(data["phoneNumber"] as? String)

        let email = clean(data["email"] as? String)

        let address =
            clean(data["address"] as? String) != "" ? clean(data["address"] as? String) :
            clean(data["location"] as? String)

        let rating: Double
        if let r = data["rating"] as? Double {
            rating = r
        } else if let r = data["rating"] as? Int {
            rating = Double(r)
        } else if let r = data["rating"] as? String, let rr = Double(r) {
            rating = rr
        } else {
            rating = 0
        }

        let reviews: Int
        if let r = data["reviews"] as? Int {
            reviews = r
        } else if let r = data["reviews"] as? Double {
            reviews = Int(r)
        } else if let r = data["reviews"] as? String, let rr = Int(r) {
            reviews = rr
        } else if let r = data["reviewsCount"] as? Int {
            reviews = r
        } else {
            reviews = 0
        }

        self.id = doc.documentID
        self.name = name
        self.desc = desc
        self.fullDescription = fullDescription
        self.rating = rating
        self.reviews = reviews
        self.phone = phone
        self.email = email
        self.address = address
    }
}
