//
//  ImageLoader.swift
//  AppPlateFul-New
//
//  Created by Hassan Fardan on 06/01/2026.
//

import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func load(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cached = cache.object(forKey: urlString as NSString) {
            completion(cached)
            return
        }

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else { return }
            let image = data.flatMap { UIImage(data: $0) }

            if let image {
                self.cache.setObject(image, forKey: urlString as NSString)
            }

            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

