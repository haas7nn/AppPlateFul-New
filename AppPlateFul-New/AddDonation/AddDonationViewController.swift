import UIKit

// Screen where the donor adds a new donation (food or other items).
class AddDonationViewController: UIViewController {
    
    // MARK: - IBOutlets (connected from storyboard)
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var foodContainer: UIView!
    @IBOutlet weak var otherContainer: UIView!
    @IBOutlet weak var foodCountLabel: UILabel!
    @IBOutlet weak var otherCountLabel: UILabel!
    
    // Food date fields
    @IBOutlet weak var foodProductionDateField: UITextField!
    @IBOutlet weak var foodExpiryDateField: UITextField!
    
    // Other date fields
    @IBOutlet weak var otherProductionDateField: UITextField!
    @IBOutlet weak var otherExpiryDateField: UITextField!
    
    // Notes buttons
    @IBOutlet weak var foodDonationNotesBtn: UIButton!
    @IBOutlet weak var foodHealthNotesBtn: UIButton!
    @IBOutlet weak var otherDonationNotesBtn: UIButton!
    @IBOutlet weak var otherHealthNotesBtn: UIButton!
    
    // Item name labels shown on the cards
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var otherNameLabel: UILabel!
    
    // MARK: - State
    
    private var foodQuantity: Int = 0
    private var otherQuantity: Int = 0
    
    private var foodProductionDate: Date = Date()
    private var foodExpiryDate: Date = Date()
    private var otherProductionDate: Date = Date()
    private var otherExpiryDate: Date = Date()
    
    // We keep notes in memory so the alert can reopen with previous text
    private var foodDonationNotes: String = ""
    private var foodHealthNotes: String = ""
    private var otherDonationNotes: String = ""
    private var otherHealthNotes: String = ""
    
    // MARK: - Cloudinary
    
    // Our Cloudinary cloud
    private let cloudName = "dnumu6zzg"
    
    // Allowed food images (public IDs in Cloudinary)
    private let foodImageOptions: [String] = [
        "chicken_shawarma",
        "Burger",
        "Taco",
        "Pasta",
        "Biryani",
        "other_items"
    ]
    
    // The currently selected image for the food card
    private var selectedFoodImageRef: String = "chicken_shawarma"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateFoodCount()
        updateOtherCount()
        updateContainerVisibility()
        setupDatePickers()
        setDefaultDates()
        setupNotesButtons()
        setupImages()
        setupNameEditing()
        setupFoodImageTap() // tap the food image to change it
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Cloudinary Helpers
    
    // Builds the Cloudinary URL for a given public ID
    private func cloudinaryURL(for publicId: String) -> URL? {
        let base = "https://res.cloudinary.com/\(cloudName)/image/upload/"
        return URL(string: base + publicId)
    }
    
    // MARK: - Setup Images
    
    private func setupImages() {
        setupFoodImage()
        setupOtherImage()
    }
    
    // Food image is always loaded from Cloudinary
    private func setupFoodImage() {
        updateFoodImageUI()
    }
    
    // Other items card still uses a static local image
    private func setupOtherImage() {
        for subview in otherContainer.subviews {
            if subview.backgroundColor == UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) ||
                subview.frame.height == 170 {
                for cardSubview in subview.subviews {
                    if cardSubview.frame.width == 120 {
                        addImageToView(cardSubview, imageName: "canned_beans")
                        return
                    }
                }
            }
        }
        findAndAddImage(in: otherContainer, width: 120, imageName: "canned_beans")
    }
    
    // Finds the image placeholder inside the food card
    private func foodImageContainer() -> UIView? {
        for subview in foodContainer.subviews {
            if subview.backgroundColor == UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) ||
                subview.frame.height == 170 {
                for cardSubview in subview.subviews {
                    if cardSubview.frame.width == 120 &&
                        !(cardSubview is UILabel) &&
                        !(cardSubview is UIButton) {
                        return cardSubview
                    }
                }
            }
        }
        return nil
    }
    
    // Recursive helper used for the static other-items image
    private func findAndAddImage(in containerView: UIView, width: CGFloat, imageName: String) {
        for subview in containerView.subviews {
            if subview.frame.width == width && !(subview is UILabel) && !(subview is UIButton) {
                addImageToView(subview, imageName: imageName)
                return
            }
            findAndAddImage(in: subview, width: width, imageName: imageName)
        }
    }
    
    /// Adds a UIImageView with a local asset. Used only by the Other card.
    private func addImageToView(_ view: UIView, imageName: String) {
        for subview in view.subviews where subview is UIImageView {
            subview.removeFromSuperview()
        }
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
    }
    
    /// Loads a Cloudinary image into the food image container
    private func loadCloudinaryImage(publicId: String, into container: UIView) {
        for sub in container.subviews where sub is UIImageView {
            sub.removeFromSuperview()
        }
        
        guard let url = cloudinaryURL(for: publicId) else { return }
        
        let imageView = UIImageView(frame: container.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(imageView)
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }.resume()
    }
    
    // MARK: - Food image dropdown
    
    // Make the food image tappable
    private func setupFoodImageTap() {
        guard let container = foodImageContainer() else { return }
        container.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(foodImageTapped))
        container.addGestureRecognizer(tap)
    }
    
    // Friendly names for the Cloudinary IDs
    private func displayName(for imageRef: String) -> String {
        switch imageRef {
        case "chicken_shawarma": return "Shawarma"
        case "Burger":           return "Burger"
        case "Taco":             return "Taco"
        case "Pasta":            return "Pasta"
        case "Biryani":          return "Biryani"
        case "other_items":      return "Other items"
        default:                 return imageRef
        }
    }
    
    // Show action sheet to choose which food image to use
    @objc private func foodImageTapped() {
        let alert = UIAlertController(title: "Select Food Item", message: nil, preferredStyle: .actionSheet)
        
        for ref in foodImageOptions {
            let title = displayName(for: ref)
            let action = UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.selectedFoodImageRef = ref
                self.updateFoodImageUI()
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Needed on iPad so the sheet has an anchor
        if let popover = alert.popoverPresentationController {
            popover.sourceView = foodContainer
            popover.sourceRect = foodContainer.bounds
        }
        
        present(alert, animated: true)
    }
    
    // Redraw food image and update name label if still placeholder
    private func updateFoodImageUI() {
        guard let container = foodImageContainer() else { return }
        loadCloudinaryImage(publicId: selectedFoodImageRef, into: container)
        
        let current = foodNameLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if current.isEmpty || current == "Enter food name" {
            foodNameLabel.text = displayName(for: selectedFoodImageRef)
        }
    }
    
    // MARK: - Name Editing
    
    // Tapping the labels lets the donor rename the items
    private func setupNameEditing() {
        foodNameLabel.text = "Enter food name"
        otherNameLabel.text = "Enter item name"
        
        foodNameLabel.isUserInteractionEnabled = true
        otherNameLabel.isUserInteractionEnabled = true
        
        let foodTap = UITapGestureRecognizer(target: self, action: #selector(foodNameTapped))
        foodNameLabel.addGestureRecognizer(foodTap)
        
        let otherTap = UITapGestureRecognizer(target: self, action: #selector(otherNameTapped))
        otherNameLabel.addGestureRecognizer(otherTap)
    }
    
    @objc private func foodNameTapped() {
        showNameEditAlert(title: "Food Name",
                          placeholder: "Enter food name",
                          label: foodNameLabel)
    }
    
    @objc private func otherNameTapped() {
        showNameEditAlert(title: "Item Name",
                          placeholder: "Enter item name",
                          label: otherNameLabel)
    }
    
    // Simple alert to edit a UILabel's text
    private func showNameEditAlert(title: String,
                                   placeholder: String,
                                   label: UILabel) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            let current = label.text ?? ""
            textField.text = (current == placeholder) ? "" : current
            textField.placeholder = placeholder
            textField.autocapitalizationType = .words
        }
        
        let save = UIAlertAction(title: "Save", style: .default) { _ in
            let text = alert.textFields?.first?.text?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            label.text = text.isEmpty ? placeholder : text
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(save)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    // MARK: - Notes Buttons
    
    private func setupNotesButtons() {
        foodDonationNotesBtn.addTarget(self, action: #selector(foodDonationNotesTapped), for: .touchUpInside)
        foodHealthNotesBtn.addTarget(self, action: #selector(foodHealthNotesTapped), for: .touchUpInside)
        otherDonationNotesBtn.addTarget(self, action: #selector(otherDonationNotesTapped), for: .touchUpInside)
        otherHealthNotesBtn.addTarget(self, action: #selector(otherHealthNotesTapped), for: .touchUpInside)
    }
    
    // Each notes button opens the same type of alert, then updates its style
    
    @objc private func foodDonationNotesTapped() {
        showNotesAlert(title: "Donation Notes", currentText: foodDonationNotes) { [weak self] newText in
            self?.foodDonationNotes = newText
            self?.updateButtonAppearance(button: self?.foodDonationNotesBtn, hasContent: !newText.isEmpty, title: "Donation Notes")
        }
    }
    
    @objc private func foodHealthNotesTapped() {
        showNotesAlert(title: "Health Notes", currentText: foodHealthNotes) { [weak self] newText in
            self?.foodHealthNotes = newText
            self?.updateButtonAppearance(button: self?.foodHealthNotesBtn, hasContent: !newText.isEmpty, title: "Health Notes")
        }
    }
    
    @objc private func otherDonationNotesTapped() {
        showNotesAlert(title: "Donation Notes", currentText: otherDonationNotes) { [weak self] newText in
            self?.otherDonationNotes = newText
            self?.updateButtonAppearance(button: self?.otherDonationNotesBtn, hasContent: !newText.isEmpty, title: "Donation Notes")
        }
    }
    
    @objc private func otherHealthNotesTapped() {
        showNotesAlert(title: "Health Notes", currentText: otherHealthNotes) { [weak self] newText in
            self?.otherHealthNotes = newText
            self?.updateButtonAppearance(button: self?.otherHealthNotesBtn, hasContent: !newText.isEmpty, title: "Health Notes")
        }
    }
    
    // Generic "enter notes" alert used by all four buttons
    private func showNotesAlert(title: String, currentText: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: "Enter your notes below:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Type your notes here..."
            textField.text = currentText
            textField.autocapitalizationType = .sentences
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            completion(text)
        }
        saveAction.setValue(UIColor(red: 0.678, green: 0.757, blue: 0.580, alpha: 1.0), forKey: "titleTextColor")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    // Visually indicate whether a notes button has any text yet
    private func updateButtonAppearance(button: UIButton?, hasContent: Bool, title: String) {
        guard let button = button else { return }
        
        if hasContent {
            button.backgroundColor = UIColor(red: 0.678, green: 0.757, blue: 0.580, alpha: 1.0)
            button.setTitleColor(.white, for: .normal)
            button.setTitle("✓ \(title)", for: .normal)
        } else {
            button.backgroundColor = UIColor(red: 0.914, green: 0.886, blue: 0.847, alpha: 1.0)
            button.setTitleColor(UIColor(red: 0.69, green: 0.659, blue: 0.616, alpha: 1.0), for: .normal)
            button.setTitle(title, for: .normal)
        }
    }
    
    // MARK: - Date Pickers
    
    private func setupDatePickers() {
        let foodProdPicker = UIDatePicker()
        foodProdPicker.datePickerMode = .date
        foodProdPicker.preferredDatePickerStyle = .wheels
        foodProdPicker.addTarget(self, action: #selector(foodProductionDateChanged(_:)), for: .valueChanged)
        foodProductionDateField.inputView = foodProdPicker
        
        let foodExpPicker = UIDatePicker()
        foodExpPicker.datePickerMode = .date
        foodExpPicker.preferredDatePickerStyle = .wheels
        foodExpPicker.addTarget(self, action: #selector(foodExpiryDateChanged(_:)), for: .valueChanged)
        foodExpiryDateField.inputView = foodExpPicker
        
        let otherProdPicker = UIDatePicker()
        otherProdPicker.datePickerMode = .date
        otherProdPicker.preferredDatePickerStyle = .wheels
        otherProdPicker.addTarget(self, action: #selector(otherProductionDateChanged(_:)), for: .valueChanged)
        otherProductionDateField.inputView = otherProdPicker
        
        let otherExpPicker = UIDatePicker()
        otherExpPicker.datePickerMode = .date
        otherExpPicker.preferredDatePickerStyle = .wheels
        otherExpPicker.addTarget(self, action: #selector(otherExpiryDateChanged(_:)), for: .valueChanged)
        otherExpiryDateField.inputView = otherExpPicker
        
        [foodProductionDateField, foodExpiryDateField, otherProductionDateField, otherExpiryDateField].forEach { field in
            field?.inputAccessoryView = createToolbar()
        }
    }
    
    private func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(dismissKeyboard))
        doneButton.tintColor = UIColor(red: 0.678, green: 0.757, blue: 0.580, alpha: 1.0)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        return toolbar
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setDefaultDates() {
        foodProductionDate = Date()
        foodExpiryDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        otherProductionDate = Date()
        otherExpiryDate = Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
        
        foodProductionDateField.text = dateFormatter.string(from: foodProductionDate)
        foodExpiryDateField.text = dateFormatter.string(from: foodExpiryDate)
        otherProductionDateField.text = dateFormatter.string(from: otherProductionDate)
        otherExpiryDateField.text = dateFormatter.string(from: otherExpiryDate)
    }
    
    // Each picker change keeps the backing Date in sync with the visible text
    
    @objc private func foodProductionDateChanged(_ picker: UIDatePicker) {
        foodProductionDate = picker.date
        foodProductionDateField.text = dateFormatter.string(from: picker.date)
    }
    
    @objc private func foodExpiryDateChanged(_ picker: UIDatePicker) {
        foodExpiryDate = picker.date
        foodExpiryDateField.text = dateFormatter.string(from: picker.date)
    }
    
    @objc private func otherProductionDateChanged(_ picker: UIDatePicker) {
        otherProductionDate = picker.date
        otherProductionDateField.text = dateFormatter.string(from: picker.date)
    }
    
    @objc private func otherExpiryDateChanged(_ picker: UIDatePicker) {
        otherExpiryDate = picker.date
        otherExpiryDateField.text = dateFormatter.string(from: picker.date)
    }
    
    // MARK: - Food vs Other toggle
    
    private func updateContainerVisibility() {
        let isFood = categorySegment.selectedSegmentIndex == 0
        foodContainer.isHidden = !isFood
        otherContainer.isHidden = isFood
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        updateContainerVisibility()
    }
    
    // MARK: - Food Count
    
    private func updateFoodCount() {
        foodCountLabel.text = "\(foodQuantity)"
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        if foodQuantity > 0 {
            foodQuantity -= 1
            updateFoodCount()
        }
    }
    
    @IBAction func plusTapped(_ sender: UIButton) {
        if foodQuantity < 99 {
            foodQuantity += 1
            updateFoodCount()
        }
    }
    
    // Submit FOOD donation
    @IBAction func submitTapped(_ sender: UIButton) {
        guard foodQuantity > 0 else {
            showAlert(title: "Oops!", message: "Please add at least 1 item to donate.")
            return
        }
        
        var specialNotes = ""
        if !foodDonationNotes.isEmpty {
            specialNotes += "Donation Notes: \(foodDonationNotes)"
        }
        if !foodHealthNotes.isEmpty {
            if !specialNotes.isEmpty { specialNotes += "\n" }
            specialNotes += "Health Notes: \(foodHealthNotes)"
        }
        
        let nameText = foodNameLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = (nameText?.isEmpty == false && nameText != "Enter food name") ? nameText! : "Food Item"
        
        navigateToReceipt(
            itemName: finalName,
            quantity: foodQuantity,
            merchantName: "Alfreej Shawarma's",
            donatedTo: "Helping Hands",
            specialNotes: specialNotes,
            isFood: true
        )
    }
    
    // MARK: - Other Count
    
    private func updateOtherCount() {
        otherCountLabel.text = "\(otherQuantity)"
    }
    
    @IBAction func otherMinusTapped(_ sender: UIButton) {
        if otherQuantity > 0 {
            otherQuantity -= 1
            updateOtherCount()
        }
    }
    
    @IBAction func otherPlusTapped(_ sender: UIButton) {
        if otherQuantity < 999 {
            otherQuantity += 1
            updateOtherCount()
        }
    }
    
    // Submit OTHER ITEMS donation
    @IBAction func otherSubmitTapped(_ sender: UIButton) {
        guard otherQuantity > 0 else {
            showAlert(title: "Oops!", message: "Please add at least 1 item to donate.")
            return
        }
        
        var specialNotes = ""
        if !otherDonationNotes.isEmpty {
            specialNotes += "Donation Notes: \(otherDonationNotes)"
        }
        if !otherHealthNotes.isEmpty {
            if !specialNotes.isEmpty { specialNotes += "\n" }
            specialNotes += "Health Notes: \(otherHealthNotes)"
        }
        
        let nameText = otherNameLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = (nameText?.isEmpty == false && nameText != "Enter item name") ? nameText! : "Other Item"
        
        navigateToReceipt(
            itemName: finalName,
            quantity: otherQuantity,
            merchantName: "Riffa, Bahrain.",
            donatedTo: "Care Bridge",
            specialNotes: specialNotes,
            isFood: false
        )
    }
    
    // MARK: - Simple Alert
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation + Firestore
    
    // Builds a Donation object, saves it, and opens the receipt screen
    // MARK: - Navigation + Firestore
    private func navigateToReceipt(itemName: String,
                                   quantity: Int,
                                   merchantName: String,
                                   donatedTo: String,
                                   specialNotes: String,
                                   isFood: Bool) {
        let expiry: Date? = isFood ? foodExpiryDate : otherExpiryDate

        // 1) Decide which public ID to use
        let publicId = isFood ? selectedFoodImageRef : "other_items"

        // 2) Build a full Cloudinary URL string and store that
        let fullImageURLString = cloudinaryURL(for: publicId)?.absoluteString ?? publicId
        let imageRef = fullImageURLString
        
        // These should be filled with the logged-in user's details
        
        let donorId = UserSession.shared.userId ?? "unknown_donor"
        let donorName = "Donor"
        
        let status: DonationStatus = .pending
        let scheduledPickup: PickupSchedule? = nil
        
        let donation = Donation(
            id: UUID().uuidString,
            title: itemName,
            description: specialNotes,
            quantity: String(quantity),
            expiryDate: expiry,
            imageRef: imageRef,          // now holds full URL, not just ID
            donorId: donorId,
            donorName: donorName,
            ngoId: donatedTo,
            status: status,
            scheduledPickup: scheduledPickup
        )
        
        DonationService.shared.createDonation(donation) { error in
            if let error = error {
                print("Failed to create donation in Firestore:", error)
            }
        }
        
        guard let receiptVC = storyboard?.instantiateViewController(
            withIdentifier: "DonationReceiptViewController"
        ) as? DonationReceiptViewController else {
            print("Error: Could not find DonationReceiptViewController in storyboard")
            return
        }
        receiptVC.itemName = itemName
        receiptVC.quantity = quantity
        receiptVC.merchantName = merchantName
        receiptVC.donatedTo = donatedTo
        receiptVC.specialNotes = specialNotes
        receiptVC.expiryDate = expiry
        navigationController?.pushViewController(receiptVC, animated: true)
    }
}
