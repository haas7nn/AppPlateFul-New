import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()
    private var running: [String: URLSessionDataTask] = [:]
    private let lock = NSLock()

    // Returns a token you can cancel in prepareForReuse
    @discardableResult
    func load(_ urlString: String,
              into imageView: UIImageView,
              placeholder: UIImage? = nil) -> String? {

        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        imageView.image = placeholder

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        if trimmed.isEmpty { return nil }

        let key = NSString(string: trimmed)
        if let cached = cache.object(forKey: key) {
            imageView.image = cached
            return nil
        }

        guard let url = URL(string: trimmed) else { return nil }

        // cancel any previous task for same URL
        lock.lock()
        running[trimmed]?.cancel()
        lock.unlock()

        let task = URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let self else { return }
            defer {
                self.lock.lock()
                self.running[trimmed] = nil
                self.lock.unlock()
            }

            guard let imageView else { return }
            guard let data, let image = UIImage(data: data) else { return }

            self.cache.setObject(image, forKey: key)

            DispatchQueue.main.async {
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
                imageView.image = image
            }
        }

        lock.lock()
        running[trimmed] = task
        lock.unlock()

        task.resume()
        return trimmed
    }

    func cancel(_ token: String?) {
        guard let token = token else { return }
        lock.lock()
        let task = running[token]
        running[token] = nil
        lock.unlock()
        task?.cancel()
    }
}
