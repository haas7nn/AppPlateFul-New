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

    // provides the image url that the vc displays
    var imageName: String {
        return !logoURL.isEmpty ? logoURL : logoAssetName
    }

    // creates / initializes an object by parsing data stored in the firestore
    init?(doc: DocumentSnapshot) {

        // gets data from firestore or uses empty data if it's missing
        let data = doc.data() ?? [:]

        // removes whitespace and avoids nil values
        func clean(_ s: String?) -> String {
            (s ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        }

        // gets ngo names from firestore
        let name =
            clean(data["name"] as? String) != "" ? clean(data["name"] as? String) :
            clean(data["ngoName"] as? String) != "" ? clean(data["ngoName"] as? String) :
            clean(data["orgName"] as? String) != "" ? clean(data["orgName"] as? String) :
            clean(data["organizationName"] as? String)

        // stops initialization if no valid NGO name is found
        if name.isEmpty { return nil }

        // gets short description from firestore
        let desc =
            clean(data["desc"] as? String) != "" ? clean(data["desc"] as? String) :
            clean(data["tagline"] as? String) != "" ? clean(data["tagline"] as? String) :
            clean(data["description"] as? String) != "" ? clean(data["description"] as? String) :
            clean(data["about"] as? String)

        // gets the full description from firestore
        let fullDescription =
            clean(data["fullDescription"] as? String) != "" ? clean(data["fullDescription"] as? String) :
            clean(data["details"] as? String) != "" ? clean(data["details"] as? String) :
            clean(data["fullDetails"] as? String) != "" ? clean(data["fullDetails"] as? String) :
            desc

        // gets an image by URL
        let rawImage =
            clean(data["logoURL"] as? String) != "" ? clean(data["logoURL"] as? String) :
            clean(data["imageName"] as? String) != "" ? clean(data["imageName"] as? String) :
            clean(data["logoName"] as? String) != "" ? clean(data["logoName"] as? String) :
            clean(data["image"] as? String)

        // checks if the image is a URL or an asset
        let isURL = rawImage.lowercased().hasPrefix("http://") || rawImage.lowercased().hasPrefix("https://")
        self.logoURL = isURL ? rawImage : ""
        self.logoAssetName = isURL ? "" : rawImage

        // cleans the phone number value to remove spaces and checks if it's not empty
        let phone =
            clean(data["phone"] as? String) != "" ? clean(data["phone"] as? String) :
            clean(data["phoneNumber"] as? String)
        let email = clean(data["email"] as? String)

        // gets the NGO address using fallback keys.
        let address =
            clean(data["address"] as? String) != "" ? clean(data["address"] as? String) :
            clean(data["location"] as? String)

        // converts the rating value into a double even if it comes in a diff type
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

        // Converts the reviews count into an int even if it comes in a diff type
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

        // Assigns final parsed values to the model properties.
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
