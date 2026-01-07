import UIKit

class AddDonationViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var foodContainer: UIView!
    @IBOutlet weak var otherContainer: UIView!
    @IBOutlet weak var foodCountLabel: UILabel!
    @IBOutlet weak var otherCountLabel: UILabel!
    
    // Food Date TextFields
    @IBOutlet weak var foodProductionDateField: UITextField!
    @IBOutlet weak var foodExpiryDateField: UITextField!
    
    // Other Date TextFields
    @IBOutlet weak var otherProductionDateField: UITextField!
    @IBOutlet weak var otherExpiryDateField: UITextField!
    
    // Notes Buttons
    @IBOutlet weak var foodDonationNotesBtn: UIButton!
    @IBOutlet weak var foodHealthNotesBtn: UIButton!
    @IBOutlet weak var otherDonationNotesBtn: UIButton!
    @IBOutlet weak var otherHealthNotesBtn: UIButton!
    
    // MARK: - Properties
    private var foodQuantity: Int = 0
    private var otherQuantity: Int = 0
    
    private var foodProductionDate: Date = Date()
    private var foodExpiryDate: Date = Date()
    private var otherProductionDate: Date = Date()
    private var otherExpiryDate: Date = Date()
    
    // Notes storage
    private var foodDonationNotes: String = ""
    private var foodHealthNotes: String = ""
    private var otherDonationNotes: String = ""
    private var otherHealthNotes: String = ""
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Setup Images
    private func setupImages() {
        // Find and add image to Food section (Chicken Shawarma)
        setupFoodImage()
        
        // Find and add image to Other Items section (Canned Beans)
        setupOtherImage()
    }
    
    private func setupFoodImage() {
        // Find the food card image placeholder
        // Looking for FoodImg view (120x138 size) inside FoodCard inside FoodContainer
        for subview in foodContainer.subviews {
            // Find the FoodCard (green card with corner radius)
            if subview.backgroundColor == UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) ||
               subview.frame.height == 170 {
                // This is likely the FoodCard
                for cardSubview in subview.subviews {
                    // Find the image placeholder (120 width)
                    if cardSubview.frame.width == 120 {
                        addImageToView(cardSubview, imageName: "chicken_shawarma")
                        return
                    }
                }
            }
        }
        
        // Alternative: Search by traversing all subviews
        findAndAddImage(in: foodContainer, width: 120, imageName: "chicken_shawarma")
    }
    
    private func setupOtherImage() {
        // Find the other card image placeholder
        // Looking for OtherImg view (120x138 size) inside OtherCard inside OtherContainer
        for subview in otherContainer.subviews {
            // Find the OtherCard (green card with corner radius)
            if subview.backgroundColor == UIColor(red: 0.678, green: 0.757, blue: 0.58, alpha: 1.0) ||
               subview.frame.height == 170 {
                // This is likely the OtherCard
                for cardSubview in subview.subviews {
                    // Find the image placeholder (120 width)
                    if cardSubview.frame.width == 120 {
                        addImageToView(cardSubview, imageName: "canned_beans")
                        return
                    }
                }
            }
        }
        
        // Alternative: Search by traversing all subviews
        findAndAddImage(in: otherContainer, width: 120, imageName: "canned_beans")
    }
    
    private func findAndAddImage(in containerView: UIView, width: CGFloat, imageName: String) {
        for subview in containerView.subviews {
            if subview.frame.width == width && !(subview is UILabel) && !(subview is UIButton) {
                addImageToView(subview, imageName: imageName)
                return
            }
            // Recursively search in subviews
            findAndAddImage(in: subview, width: width, imageName: imageName)
        }
    }
    
    private func addImageToView(_ view: UIView, imageName: String) {
        // Remove any existing image views
        for subview in view.subviews {
            if subview is UIImageView {
                subview.removeFromSuperview()
            }
        }
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = UIImage(named: imageName)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 12
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
    }
    
    // MARK: - Notes Buttons Setup
    private func setupNotesButtons() {
        foodDonationNotesBtn.addTarget(self, action: #selector(foodDonationNotesTapped), for: .touchUpInside)
        foodHealthNotesBtn.addTarget(self, action: #selector(foodHealthNotesTapped), for: .touchUpInside)
        otherDonationNotesBtn.addTarget(self, action: #selector(otherDonationNotesTapped), for: .touchUpInside)
        otherHealthNotesBtn.addTarget(self, action: #selector(otherHealthNotesTapped), for: .touchUpInside)
    }
    
    // MARK: - Notes Button Actions
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
    
    private func updateButtonAppearance(button: UIButton?, hasContent: Bool, title: String) {
        guard let button = button else { return }
        
        if hasContent {
            // Has notes - show green background
            button.backgroundColor = UIColor(red: 0.678, green: 0.757, blue: 0.580, alpha: 1.0)
            button.setTitleColor(.white, for: .normal)
            button.setTitle("✓ \(title)", for: .normal)
        } else {
            // No notes - show original beige background
            button.backgroundColor = UIColor(red: 0.914, green: 0.886, blue: 0.847, alpha: 1.0)
            button.setTitleColor(UIColor(red: 0.69, green: 0.659, blue: 0.616, alpha: 1.0), for: .normal)
            button.setTitle(title, for: .normal)
        }
    }
    
    // MARK: - Date Picker Setup
    private func setupDatePickers() {
        // Food Production Date
        let foodProdPicker = UIDatePicker()
        foodProdPicker.datePickerMode = .date
        foodProdPicker.preferredDatePickerStyle = .wheels
        foodProdPicker.addTarget(self, action: #selector(foodProductionDateChanged(_:)), for: .valueChanged)
        foodProductionDateField.inputView = foodProdPicker
        
        // Food Expiry Date
        let foodExpPicker = UIDatePicker()
        foodExpPicker.datePickerMode = .date
        foodExpPicker.preferredDatePickerStyle = .wheels
        foodExpPicker.addTarget(self, action: #selector(foodExpiryDateChanged(_:)), for: .valueChanged)
        foodExpiryDateField.inputView = foodExpPicker
        
        // Other Production Date
        let otherProdPicker = UIDatePicker()
        otherProdPicker.datePickerMode = .date
        otherProdPicker.preferredDatePickerStyle = .wheels
        otherProdPicker.addTarget(self, action: #selector(otherProductionDateChanged(_:)), for: .valueChanged)
        otherProductionDateField.inputView = otherProdPicker
        
        // Other Expiry Date
        let otherExpPicker = UIDatePicker()
        otherExpPicker.datePickerMode = .date
        otherExpPicker.preferredDatePickerStyle = .wheels
        otherExpPicker.addTarget(self, action: #selector(otherExpiryDateChanged(_:)), for: .valueChanged)
        otherExpiryDateField.inputView = otherExpPicker
        
        // Add toolbar with Done button to all date fields
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
        // Set default dates
        foodProductionDate = Date()
        foodExpiryDate = Calendar.current.date(byAdding: .month, value: 3, to: Date()) ?? Date()
        otherProductionDate = Date()
        otherExpiryDate = Calendar.current.date(byAdding: .year, value: 2, to: Date()) ?? Date()
        
        // Update text fields
        foodProductionDateField.text = dateFormatter.string(from: foodProductionDate)
        foodExpiryDateField.text = dateFormatter.string(from: foodExpiryDate)
        otherProductionDateField.text = dateFormatter.string(from: otherProductionDate)
        otherExpiryDateField.text = dateFormatter.string(from: otherExpiryDate)
    }
    
    // MARK: - Date Changed Actions
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
    
    // MARK: - Container Toggle
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
    
    @IBAction func submitTapped(_ sender: UIButton) {
        guard foodQuantity > 0 else {
            showAlert(title: "Oops!", message: "Please add at least 1 item to donate.")
            return
        }
        
        // Combine notes
        var specialNotes = ""
        if !foodDonationNotes.isEmpty {
            specialNotes += "Donation Notes: \(foodDonationNotes)"
        }
        if !foodHealthNotes.isEmpty {
            if !specialNotes.isEmpty { specialNotes += "\n" }
            specialNotes += "Health Notes: \(foodHealthNotes)"
        }
        
        navigateToReceipt(
            itemName: "Chicken Shawarma Meal",
            quantity: foodQuantity,
            merchantName: "Alfreej Shawarma's",
            donatedTo: "Helping Hands",
            specialNotes: specialNotes
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
    
    @IBAction func otherSubmitTapped(_ sender: UIButton) {
        guard otherQuantity > 0 else {
            showAlert(title: "Oops!", message: "Please add at least 1 item to donate.")
            return
        }
        
        // Combine notes
        var specialNotes = ""
        if !otherDonationNotes.isEmpty {
            specialNotes += "Donation Notes: \(otherDonationNotes)"
        }
        if !otherHealthNotes.isEmpty {
            if !specialNotes.isEmpty { specialNotes += "\n" }
            specialNotes += "Health Notes: \(otherHealthNotes)"
        }
        
        navigateToReceipt(
            itemName: "Canned Beans",
            quantity: otherQuantity,
            merchantName: "Riffa, Bahrain.",
            donatedTo: "Care Bridge",
            specialNotes: specialNotes
        )
    }
    
    // MARK: - Helper
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    private func navigateToReceipt(itemName: String, quantity: Int, merchantName: String, donatedTo: String, specialNotes: String) {
        guard let receiptVC = storyboard?.instantiateViewController(withIdentifier: "DonationReceiptViewController") as? DonationReceiptViewController else {
            print("Error: Could not find DonationReceiptViewController in storyboard")
            return
        }
        receiptVC.itemName = itemName
        receiptVC.quantity = quantity
        receiptVC.merchantName = merchantName
        receiptVC.donatedTo = donatedTo
        receiptVC.specialNotes = specialNotes
        navigationController?.pushViewController(receiptVC, animated: true)
    }
}
