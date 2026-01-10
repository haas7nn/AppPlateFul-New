import UIKit
import FirebaseAuth

final class SettingsViewController: UIViewController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleAllButtons()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "view")
    }
    
    // MARK: - Button Styling
    private func styleAllButtons() {
        // Find all buttons in the view and style them
        for subview in view.subviews {
            if let button = subview as? UIButton {
                styleButton(button)
            }
            // Check nested views too
            for nestedView in subview.subviews {
                if let button = nestedView as? UIButton {
                    styleButton(button)
                }
            }
        }
    }
    
    private func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        button.superview?.clipsToBounds = false
    }
    
    // MARK: - Sign Out Action
    @IBAction func didTapSignOut(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Sign Out",
            message: "Are you sure you want to sign out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { [weak self] _ in
            self?.performSignOut()
        })
        
        present(alert, animated: true)
    }
    
    private func performSignOut() {
        do {
            try Auth.auth().signOut()
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let loginVC = storyboard.instantiateInitialViewController() {
                    window.rootViewController = loginVC
                    window.makeKeyAndVisible()
                }
            }
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
}
