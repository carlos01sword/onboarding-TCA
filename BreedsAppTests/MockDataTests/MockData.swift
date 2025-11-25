import ComposableArchitecture
import SwiftUI
@testable import Breeds


enum MockData {

    static func makeBreed(id: String) -> Breed {
        return Breed(
            id: id,
            name: "Breed \(id)",
            origin: "Origin \(id)",
            temperament: "Temperament \(id)",
            description: "Description \(id)",
            lifeSpan: "12-15",
            referenceImageID: "0XYvRd7oD"
        )
    }

    static let breed1 = MockData.makeBreed(id: "1")
    static let breed2 = MockData.makeBreed(id: "2")
    static let favoritedBreed1 = MockData.makeBreed(id: "1")

    static func makeState(breeds: [Breed] = [], favorites: [Breed] = []) -> BreedListReducer.State {
        let sharedFavorites = Shared(value: IdentifiedArray(uniqueElements: favorites))
        var state = BreedListReducer.State(favoriteBreeds: sharedFavorites)
        let cellStates = breeds.map {
            BreedCellReducer.State(breed: $0, favoriteBreeds: sharedFavorites)
        }

        state.breeds = IdentifiedArray(uniqueElements: cellStates)
        return state
    }

    struct TestError: LocalizedError, Equatable {
        var errorDescription: String? { "Network error" }
    }
}
