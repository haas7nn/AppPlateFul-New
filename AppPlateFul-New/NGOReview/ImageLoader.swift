//
//  ImageLoader.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import Foundation
import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    // For canceling in reusable cells
    private var running: [String: URLSessionDataTask] = [:]
    private let lock = NSLock()

    // MARK: - 1) Your version: completion-based
    func load(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty, let url = URL(string: trimmed) else {
            DispatchQueue.main.async { completion(nil) }
            return
        }

        let key = NSString(string: trimmed)

        if let cached = cache.object(forKey: key) {
            DispatchQueue.main.async { completion(cached) }
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }

            guard let data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self.cache.setObject(image, forKey: key)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }

    // MARK: - 2) Friend version: set directly into imageView + cancel token
    // Returns token you can cancel in prepareForReuse
    @discardableResult
    func load(_ urlString: String,
              into imageView: UIImageView,
              placeholder: UIImage? = nil,
              contentMode: UIView.ContentMode = .scaleAspectFit) -> String? {

        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)

        DispatchQueue.main.async {
            imageView.image = placeholder
            imageView.contentMode = contentMode
            imageView.clipsToBounds = true
        }

        if trimmed.isEmpty { return nil }

        let key = NSString(string: trimmed)

        if let cached = cache.object(forKey: key) {
            DispatchQueue.main.async {
                imageView.image = cached
                imageView.contentMode = contentMode
                imageView.clipsToBounds = true
            }
            return nil
        }

        guard let url = URL(string: trimmed) else { return nil }

        // Cancel any previous task for same URL token
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

            guard let data, let image = UIImage(data: data) else { return }

            self.cache.setObject(image, forKey: key)

            DispatchQueue.main.async {
                guard let imageView else { return }
                imageView.image = image
                imageView.contentMode = contentMode
                imageView.clipsToBounds = true
            }
        }

        lock.lock()
        running[trimmed] = task
        lock.unlock()

        task.resume()
        return trimmed
    }

    func cancel(_ token: String?) {
        guard let token else { return }
        lock.lock()
        let task = running[token]
        running[token] = nil
        lock.unlock()
        task?.cancel()
    }

    // Optional helpers
    func clearCache() {
        cache.removeAllObjects()
    }
}
