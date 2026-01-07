//
//  ImageLoader.swift
//  AppPlateFul
//
//  202301686 - Hasan
//

import Foundation
import UIKit

// Handles asynchronous image loading with caching
final class ImageLoader {

    // Shared singleton instance
    static let shared = ImageLoader()
    
    // In-memory cache for downloaded images
    private let cache = NSCache<NSString, UIImage>()

    // Prevents external initialization
    private init() {}

    // Loads image from URL string with caching support
    func load(_ urlString: String, completion: @escaping (UIImage?) -> Void) {
        
        // Validate URL string
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            completion(nil)
            return
        }

        // Return cached image if available
        if let cached = cache.object(forKey: urlString as NSString) {
            completion(cached)
            return
        }

        // Download image asynchronously
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else {
                completion(nil)
                return
            }

            // Cache downloaded image
            self.cache.setObject(image, forKey: urlString as NSString)
            completion(image)
        }.resume()
    }
}
