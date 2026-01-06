import UIKit
import FirebaseFirestore

final class FavoriteNGOsViewController: UIViewController,
                                       UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {

    @IBOutlet private weak var collectionView: UICollectionView!

    private let db = Firestore.firestore()
    private var favorites: [FavoriteNGO] = []

    private var userId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? "guest"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorite NGOs"

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        fetchFavorites()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func fetchFavorites() {
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .getDocuments { [weak self] snap, _ in
                self?.favorites = snap?.documents.compactMap {
                    FavoriteNGO(doc: $0)
                } ?? []

                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
    }

    @IBAction private func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - DataSource
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        favorites.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "FavoriteNGOCell",
            for: indexPath
        ) as! FavoriteNGOCell

        let ngo = favorites[indexPath.item]
        cell.nameLabel.text = ngo.name
        cell.descriptionLabel.text = ngo.desc
        cell.logoImageView.image = UIImage(named: ngo.imageName)
            ?? UIImage(systemName: "photo")

        cell.onLearnMoreTapped = { [weak self] in
            self?.openDetails(for: ngo)
        }

        return cell
    }

    private func openDetails(for ngo: FavoriteNGO) {
        let sb = UIStoryboard(name: "FavoriteNGOs", bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "FavoriteNGODetailsViewController"
        ) as! FavoriteNGODetailsViewController
        vc.ngo = ngo
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 48) / 2
        return CGSize(width: width, height: 300)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat { 16 }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { 16 }
}
