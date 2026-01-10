import UIKit
import FirebaseAuth
import FirebaseFirestore

final class ProfileViewController: UIViewController {

    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        styleButtons()
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "view")
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
    }

    private func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No user in Profile")
            return
        }

        db.collection("users").document(uid).getDocument { [weak self] snap, err in
            guard let self = self else { return }

            if let err = err {
                print("❌ loadProfile error:", err.localizedDescription)
                return
            }

            let data = snap?.data() ?? [:]

            // ✅ fallback عشان لو عندك بيانات قديمة محفوظة بـ "name"
            let fullName = (data["fullName"] as? String)
                ?? (data["name"] as? String)
                ?? "—"

            let email = (data["email"] as? String)
                ?? (Auth.auth().currentUser?.email ?? "—")

            let phone = (data["phone"] as? String) ?? "—"

            DispatchQueue.main.async {
                // ✅ أعلى الكارد (الاسم والايميل)
                (self.view.viewWithTag(201) as? UILabel)?.text = fullName
                (self.view.viewWithTag(202) as? UILabel)?.text = email

                // ✅ داخل Personal Information
                (self.view.viewWithTag(203) as? UILabel)?.text = fullName
                (self.view.viewWithTag(204) as? UILabel)?.text = email
                (self.view.viewWithTag(205) as? UILabel)?.text = phone
            }
        }
    }

    // --- نفس ستايل أزرارك ---
    private func styleButtons() {
        if let btn = view.viewWithTag(101) as? UIButton { styleButton(btn, isSignOut: false) }
        if let btn = view.viewWithTag(102) as? UIButton { styleButton(btn, isSignOut: false) }
        if let btn = view.viewWithTag(103) as? UIButton { styleButton(btn, isSignOut: true) }
    }

    private func styleButton(_ button: UIButton, isSignOut: Bool) {
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        button.clipsToBounds = false

        if isSignOut {
            button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        }

        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.1
        button.layer.shadowRadius = 10
        button.layer.shadowOffset = CGSize(width: 0, height: 5)

        button.superview?.clipsToBounds = false
    }

    // --- Sign out ---
    @IBAction func didTapSignOut(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sign Out",
                                      message: "Are you sure you want to sign out?",
                                      preferredStyle: .alert)

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
                let sb = UIStoryboard(name: "Main", bundle: nil)
                if let loginVC = sb.instantiateInitialViewController() {
                    window.rootViewController = loginVC
                    window.makeKeyAndVisible()
                }
            }
        } catch {
            print("Sign out error:", error.localizedDescription)
        }
    }
}

