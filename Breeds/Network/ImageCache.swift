import SwiftUI

enum ImageCache {
    private static let memoryCache = NSCache<NSString, UIImage>()

    static func getCachedImage(for id: String?, diskCache: ImageDiskCache) -> UIImage? {
        guard let id else { return nil }
        let key = id as NSString

        if let cached = memoryCache.object(forKey: key) {
            return cached
        }

        guard let data = diskCache[id],
              let image = UIImage(data: data)
        else {
            return nil
        }

        memoryCache.setObject(image, forKey: key)
        return image
    }

    static func setCachedImage(_ image: UIImage, id: String, diskCache: inout ImageDiskCache, data: Data? = nil) {
        let key = id as NSString
        memoryCache.setObject(image, forKey: key)

        if let data = data ?? image.pngData() {
            diskCache[id] = data
        }
    }

    // LOOKUP FOR THE IMAGECARDVIEW
    static func getSynchronously(for id: String?) -> UIImage? {
        guard let id else { return nil }
        return memoryCache.object(forKey: id as NSString)
    }
}
