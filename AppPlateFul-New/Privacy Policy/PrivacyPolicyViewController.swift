//
//  PrivacyPolicyViewController.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

// Displays the application's privacy policy content
class PrivacyPolicyViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    // Configures base UI appearance
    private func setupUI() {
        view.backgroundColor =
            UIColor(red: 0.969, green: 0.957, blue: 0.937, alpha: 1)
        
        // Title is handled inside the content view
        navigationItem.title = ""
    }
    
    // MARK: - Actions
    // Navigates back to previous screen
    @IBAction func backTapped(_ sender: Any) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
