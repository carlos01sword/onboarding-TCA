import SwiftUI
import ComposableArchitecture

enum ImageCache {
    private static let memoryCache = LockIsolated(NSCache<NSString, UIImage>())
    @Shared(.imageDiskCache) private static var diskCache

    static func getCachedImage(for id: String) -> UIImage? {

        if let cached = memoryCache.withValue({ cache in
            let key = id as NSString
            return cache.object(forKey: key)
        }) {
            return cached
        }

        let cachedData: Data? = $diskCache.withLock { disk in
            disk[id]
        }

        guard let data = cachedData, let image = UIImage(data: data)
        else {
            return nil
        }

        memoryCache.withValue { cache in
            let key = id as NSString
            cache.setObject(image, forKey: key)
        }

        return image
    }

    static func setCachedImage(_ image: UIImage, id: String, data: Data? = nil) {
        memoryCache.withValue { cache in
            let key = id as NSString
            cache.setObject(image, forKey: key)
        }

        Self.$diskCache.withLock { diskCache in
            if let data = data ?? image.pngData() {
                diskCache[id] = data
            }
        }
    }
}

struct ImageCacheDependency: DependencyKey {
    var getCachedImage: (_ id: String) -> UIImage?
    var setCachedImage:  (_ image: UIImage, _ id: String, _ data: Data?) -> Void

    static let liveValue = Self(
        getCachedImage: { id in
            ImageCache.getCachedImage(for: id)
        },
        setCachedImage: { image, id, data in
            ImageCache.setCachedImage(image, id: id, data: data)
        }
    )

    static let testValue = Self(
        getCachedImage: { _ in nil },
        setCachedImage: { _, _, _ in }
    )
}

extension DependencyValues {
    var imageCache: ImageCacheDependency {
        get { self[ImageCacheDependency.self] }
        set { self[ImageCacheDependency.self] = newValue }
    }
}
