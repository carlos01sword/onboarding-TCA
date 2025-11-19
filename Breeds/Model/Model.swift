import ComposableArchitecture
import SwiftUI
import Sharing

nonisolated struct Breed: Equatable, Identifiable, Codable {
    let id: String
    let name: String
    let origin: String
    let temperament: String
    let description: String
    let lifeSpan: String
    let referenceImageID: String?

    enum CodingKeys: String, CodingKey { case id, name, origin, temperament, description, lifeSpan, referenceImageID }
}

extension SharedKey where Self == FileStorageKey<IdentifiedArrayOf<Breed>>.Default {
  static var favoriteBreeds: Self {
    Self[.fileStorage(.documentsDirectory.appending(component: "user-favorites.json")),
      default: []
    ]
  }
}

typealias ImageDiskCache = [String: Data]

extension SharedKey where Self == FileStorageKey<ImageDiskCache>.Default {
    nonisolated static var imageDiskCache: Self {
        Self[.fileStorage(.cachesDirectory.appending(component: "image-disk-cache.json")),
             default: [:]
        ]
    }
}

enum MockData {
    static var sampleBreed = Breed(
        id: "01",
        name: "Cat meow meow",
        origin: "meow meow land",
        temperament: "very meow",
        description:
            "meow meows all around the world. Meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow meow",
        lifeSpan: "10-20",
        referenceImageID: "0XYvRd7oD",
    )
}
