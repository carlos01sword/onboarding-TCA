struct BreedDTO: Decodable {
    let id: String
    let name: String
    let description: String
    let origin: String
    let temperament: String
    let lifeSpan: String
    let referenceImageId: String?
}

extension BreedDTO {
    nonisolated var breed: Breed {
        .init(
            id: self.id,
            name: self.name,
            origin: self.origin,
            temperament: self.temperament,
            description: self.description,
            lifeSpan: self.lifeSpan,
            referenceImageID: self.referenceImageId
        )
    }
}

nonisolated struct CatImage: Decodable {
    let id: String
    let url: String
}
