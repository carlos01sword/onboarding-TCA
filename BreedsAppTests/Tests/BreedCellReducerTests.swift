import Testing
import ComposableArchitecture
@testable import Breeds
import SwiftUI

@Suite("Breed Cell Feature - Favorites")
@MainActor
struct BreedCellReducerTests {

    @Test func favoriteButtonTogglesStateOn() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())
        let store = TestStore(
            initialState: BreedCellReducer.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { BreedCellReducer() }
        )

        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                favorites.append(breed)
            }
        }
    }

    @Test func favoriteButtonTogglesStateOff() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf(uniqueElements: [breed]))

        let store = TestStore(
            initialState: BreedCellReducer.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { BreedCellReducer() }
        )

        await store.send(.favoriteButtonTapped) {
            $0.$favoriteBreeds.withLock { favorites in
                _ = favorites.remove(id: breed.id)
            }
        }
    }

    @Test
    func fetchImageSuccess() async {
        let breed = MockData.breed1
        let mockImage = UIImage(systemName: "photo")!
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())
        let store = TestStore(
            initialState: BreedCellReducer.State(
                breed: breed,
                favoriteBreeds: sharedFavorites
            ),
            reducer: { BreedCellReducer() }
        )

        store.dependencies.imageClient.fetchImage = { id in
            return mockImage
        }

        await store.send(.fetchImage) {
            $0.isLoadingImage = true
        }

        await store.receive(.imageResponse(.success(mockImage))) {
            $0.isLoadingImage = false
        }
    }
}
