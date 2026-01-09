import UIKit
import MapKit

class HistoryDetailsViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var restaurantLabel: UILabel!
    @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var pickupDateLabel: UILabel!
    @IBOutlet weak var finalStatusLabel: UILabel!

    // Container view holding both address and mobile labels
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!

    // MARK: - Properties
    var history: DonationHistory?

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        return formatter
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    

    // MARK: - Setup UI
    private func setupUI() {
        guard let history = history else { return }

        imageView.image = UIImage(named: history.imageName)
        restaurantLabel.text = history.restaurantName
        itemsLabel.text = "Items: \(history.itemsWithQuantity)"
        dateLabel.text = " \(dateFormatter.string(from: history.date))"
        pickupDateLabel.text = "Pickup: \(dateFormatter.string(from: history.pickupDate))"
        finalStatusLabel.text = "Status: \(history.finalStatus)"

        // Address
        if let addressText = formattedAddress(from: history) {
            let attributed = NSMutableAttributedString(string: addressText)
            if let range = addressText.range(of: "Delivery Address:") {
                let nsRange = NSRange(range, in: addressText)
                attributed.addAttribute(.font,
                                        value: UIFont.boldSystemFont(ofSize: addressLabel.font.pointSize),
                                        range: nsRange)
            }
            addressLabel.attributedText = attributed
            addressLabel.numberOfLines = 0
            addressLabel.lineBreakMode = .byWordWrapping
            addressLabel.textColor = .systemBlue
            addressLabel.isHidden = false
        } else {
            addressLabel.isHidden = true
        }

        // Mobile
        if let phone = history.mobileNumber, !phone.isEmpty {
            mobileNumberLabel.text = "Mobile: \(phone)"
            mobileNumberLabel.textColor = .systemBlue
            mobileNumberLabel.numberOfLines = 1
            mobileNumberLabel.isHidden = false
        } else {
            mobileNumberLabel.isHidden = true
        }

        // Ensure container view is visible
        containerView.isHidden = addressLabel.isHidden && mobileNumberLabel.isHidden
        containerView.isUserInteractionEnabled = true
    }

    // MARK: - Format Address
    private func formattedAddress(from history: DonationHistory) -> String? {
        guard let house = history.house,
              let road = history.road,
              let block = history.block,
              let area = history.area,
              !house.isEmpty || !road.isEmpty || !block.isEmpty || !area.isEmpty else { return nil }

        return "House: \(house), Road \(road), Block \(block), \(area)"
    }

    // MARK: - Setup Gestures
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
    }

    @objc private func containerTapped(_ sender: UITapGestureRecognizer) {
        let locationInContainer = sender.location(in: containerView)

        // Convert location to label's coordinate space
        let locationInAddress = containerView.convert(locationInContainer, to: addressLabel)
        let locationInPhone = containerView.convert(locationInContainer, to: mobileNumberLabel)

        if addressLabel.bounds.contains(locationInAddress) {
            openMap()
        } else if mobileNumberLabel.bounds.contains(locationInPhone) {
            callNumber()
        }
    }

    // MARK: - Actions
    @objc func callNumber() {
        guard let phone = history?.mobileNumber, !phone.isEmpty else {
            print("No phone number available")
            return
        }

        // Remove spaces or extra characters
        let digits = phone.filter("0123456789+".contains)
        if let url = URL(string: "tel://\(digits)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            print("Cannot open phone URL")
        }
    }

    @objc func openMap() {
        guard let history = history,
              let house = history.house,
              let road = history.road,
              let block = history.block,
              let area = history.area else {
            print("No address available")
            return
        }

        let addressString = "House: \(house), Road: \(road), Block: \(block), \(area)"
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first else {
                print("No placemarks found")
                return
            }

            let mkPlacemark = MKPlacemark(placemark: placemark)
            let mapItem = MKMapItem(placemark: mkPlacemark)
            mapItem.name = history.restaurantName
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupGestures()
    }
}
