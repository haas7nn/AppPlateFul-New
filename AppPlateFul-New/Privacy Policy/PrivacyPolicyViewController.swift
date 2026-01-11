//
//  PrivacyPolicyViewController.swift
//  AppPlateFul
//

import UIKit

/// Displays the app’s Privacy Policy content inside a scrollable view.
/// The screen uses a custom back button, so the default navigation bar is hidden.
final class PrivacyPolicyViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide system navigation bar to match the custom header design.
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore navigation bar when leaving this screen.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Cleaner reading experience without scroll indicators.
        scrollView.showsVerticalScrollIndicator = false
    }

    // MARK: - Actions
    /// Handles back navigation for both push and modal presentations.
    @IBAction private func backButtonTapped(_ sender: UIButton) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        }
    }
}
