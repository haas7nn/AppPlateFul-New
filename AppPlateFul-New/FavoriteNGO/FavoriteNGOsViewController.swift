import UIKit
import FirebaseFirestore

final class FavoriteNGOsViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {

    @IBOutlet private weak var collectionView: UICollectionView!

    private let db = Firestore.firestore()
    private var favorites: [FavoriteNGO] = []

    private var userId: String {
        guard let id = UserSession.shared.userId else {
            fatalError("userId accessed but no user is logged in")
        }
        return id
    }
    private let gridInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    private let gridSpacing: CGFloat = 16
    private let columns: CGFloat = 2

    private var didFetchOnce = false
    private var didReloadAfterGettingSize = false

    override func viewDidLoad() {
        super.viewDidLoad()

        print("🔥 FavoriteNGOsViewController viewDidLoad")
        print("✅ collectionView is nil?", collectionView == nil)
        print("✅ frame:", collectionView.frame)

        title = "Favorite NGOs"
        setupNav()
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if didFetchOnce == false {
            didFetchOnce = true
            fetchFavorites()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // This ONLY helps after storyboard constraints are fixed.
        if didReloadAfterGettingSize { return }
        if collectionView.bounds.height <= 1 { return }

        didReloadAfterGettingSize = true
        print("✅ got size, reloading. bounds:", collectionView.bounds)
        collectionView.reloadData()
    }

    private func setupNav() {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backToDonorHome)
        )
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true

        let layout: UICollectionViewFlowLayout
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout = flow
        } else {
            layout = UICollectionViewFlowLayout()
            collectionView.collectionViewLayout = layout
        }

        layout.sectionInset = gridInsets
        layout.minimumLineSpacing = gridSpacing
        layout.minimumInteritemSpacing = gridSpacing
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = .zero
    }

    @objc private func backToDonorHome() {
        guard let nav = navigationController else { return }

        if let donorHome = nav.viewControllers.first(where: { $0 is DonorHomeScreenViewController }) {
            nav.popToViewController(donorHome, animated: true)
        } else {
            nav.popToRootViewController(animated: true)
        }
    }

    private func fetchFavorites() {
        print("PATH: users/\(userId)/favorites")
        print("✅ window nil?:", collectionView.window == nil)
        print("✅ bounds:", collectionView.bounds)

        db.collection("users")
            .document(userId)
            .collection("favorites")
            .getDocuments { [weak self] snap, error in
                guard let self else { return }

                if let error = error {
                    print("Fetch favorites ids error:", error.localizedDescription)
                    return
                }

                let favDocs = snap?.documents ?? []
                let ngoIds = favDocs.map { $0.documentID }

                print("Favorite IDs:", ngoIds.count)

                if ngoIds.isEmpty {
                    self.favorites = []
                    DispatchQueue.main.async {
                        self.collectionView.layoutIfNeeded()
                        self.collectionView.reloadData()
                        print("✅ visibleCells:", self.collectionView.visibleCells.count)
                    }
                    return
                }

                self.fetchNgoDocs(ids: ngoIds)
            }
    }

    private func fetchNgoDocs(ids: [String]) {
        let chunks = stride(from: 0, to: ids.count, by: 10).map {
            Array(ids[$0..<min($0 + 10, ids.count)])
        }

        var all: [FavoriteNGO] = []
        let group = DispatchGroup()

        for chunk in chunks {
            group.enter()

            db.collection("ngo_reviews")
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments { snap, error in
                    defer { group.leave() }

                    if let error = error {
                        print("Fetch ngo_reviews error:", error.localizedDescription)
                        return
                    }

                    let docs = snap?.documents ?? []
                    all.append(contentsOf: docs.compactMap { FavoriteNGO(doc: $0) })
                }
        }

        group.notify(queue: .main) {
            let dict = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })
            self.favorites = ids.compactMap { dict[$0] }

            print("Favorites loaded:", self.favorites.count)
            print("✅ bounds at reload:", self.collectionView.bounds)
            print("✅ window nil?:", self.collectionView.window == nil)

            self.collectionView.layoutIfNeeded()
            self.collectionView.reloadData()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                print("✅ visibleCells after reload:", self.collectionView.visibleCells.count)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("✅ numberOfItemsInSection:", favorites.count)
        return favorites.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        print("✅ cellForItemAt:", indexPath.item)

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteNGOCell", for: indexPath)

        guard let typed = cell as? FavoriteNGOCell else {
            print("❌ Cell is not FavoriteNGOCell. Fix storyboard class/reuse id.")
            cell.contentView.backgroundColor = .systemRed
            return cell
        }

        let ngo = favorites[indexPath.item]
        typed.nameLabel.text = ngo.name
        typed.descriptionLabel.text = ngo.desc
        typed.configureImage(imageNameOrURL: ngo.imageName)

        typed.contentView.backgroundColor = .systemRed

        typed.onLearnMoreTapped = { [weak self] in
            self?.openDetails(for: ngo)
        }

        return typed
    }

    private func openDetails(for ngo: FavoriteNGO) {
        let sb = UIStoryboard(name: "FavoriteNGOs", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "FavoriteNGODetailsViewController") as! FavoriteNGODetailsViewController
        vc.ngo = ngo
        navigationController?.pushViewController(vc, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let totalSpacing = gridInsets.left + gridInsets.right + (gridSpacing * (columns - 1))
        let itemWidth = (collectionView.bounds.width - totalSpacing) / columns
        return CGSize(width: itemWidth, height: 300)
    }
}
