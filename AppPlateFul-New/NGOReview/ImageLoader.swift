//
//  ImageLoader.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import UIKit

/// Lightweight image loader with in-memory caching and request cancellation.
/// Designed for use with table/collection view cells to avoid flickering and wrong images.
final class ImageLoader {

    // MARK: - Singleton
    static let shared = ImageLoader()
    private init() {}

    // MARK: - Cache
    /// Stores downloaded images in memory for fast reuse.
    private let cache = NSCache<NSString, UIImage>()

    // MARK: - Running Tasks
    /// Keeps track of active downloads so they can be cancelled (important for reusable cells).
    private var running: [String: URLSessionDataTask] = [:]
    private let lock = NSLock()

    // MARK: - Version 1: Completion-based loader
    /// Loads an image from a URL string and returns it via a completion handler.
    /// Useful when you don't want direct coupling to a UIImageView.
    func load(_ urlString: String, completion: @escaping (UIImage?) -> Void) {

        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Validate URL input
        guard !trimmed.isEmpty, let url = URL(string: trimmed) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        let key = NSString(string: trimmed)

        // Return cached image if available
        if let cached = cache.object(forKey: key) {
            DispatchQueue.main.async { completion(cached) }
            return
        }

        // Download image
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }

            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            // Cache and return image
            self.cache.setObject(image, forKey: key)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }

    // MARK: - Version 2: ImageView-based loader with cancellation
    /// Loads an image directly into a UIImageView.
    /// Returns a token that can be cancelled in `prepareForReuse`.
    @discardableResult
    func load(
        _ urlString: String,
        into imageView: UIImageView,
        placeholder: UIImage? = nil,
        contentMode: UIView.ContentMode = .scaleAspectFit
    ) -> String? {

        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        // Set placeholder immediately for better UX
        DispatchQueue.main.async {
            imageView.image = placeholder
            imageView.contentMode = contentMode
            imageView.clipsToBounds = true
        }

        if trimmed.isEmpty { return nil }

        let key = NSString(string: trimmed)

        // Use cached image if available
        if let cached = cache.object(forKey: key) {
            DispatchQueue.main.async {
                imageView.image = cached
                imageView.contentMode = contentMode
                imageView.clipsToBounds = true
            }
            return nil
        }

        guard let url = URL(string: trimmed) else { return nil }

        // Cancel any existing task for this URL
        lock.lock()
        running[trimmed]?.cancel()
        lock.unlock()

        let task = URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let self else { return }

            // Ensure task cleanup even if it fails
            defer {
                self.lock.lock()
                self.running[trimmed] = nil
                self.lock.unlock()
            }

            guard let data, let image = UIImage(data: data) else { return }

            // Cache image
            self.cache.setObject(image, forKey: key)

            // Apply image safely on main thread
            DispatchQueue.main.async {
                guard let imageView else { return }
                imageView.image = image
                imageView.contentMode = contentMode
                imageView.clipsToBounds = true
            }
        }

        // Track task so it can be cancelled later
        lock.lock()
        running[trimmed] = task
        lock.unlock()

        task.resume()
        return trimmed
    }

    // MARK: - Cancellation
    /// Cancels an in-flight image request using its token.
    func cancel(_ token: String?) {
        guard let token else { return }

        lock.lock()
        let task = running[token]
        running[token] = nil
        lock.unlock()

        task?.cancel()
    }

    // MARK: - Cache Management
    /// Clears all cached images (useful for memory warnings or logout).
    func clearCache() {
        cache.removeAllObjects()
    }
}
