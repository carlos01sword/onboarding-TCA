import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Breed List Feature – Favorites")
@MainActor
struct BreedListReducerTests {

    @Test
    func togglingBreedAddsToFavorites() async {
        let breed = MockData.breed1
        let store = TestStore(initialState: MockData.makeState(breeds: [breed])) {
            BreedListReducer()
        }

        await store.send(.breeds(.element(id: breed.id, action: .favoriteButtonTapped))) {
            $0.$favoriteBreeds.withLock { $0.append(breed) }
        }
    }

    @Test
    func togglingBreedRemovesFromFavorites() async {
        let favorited = MockData.favoritedBreed1
        let store = TestStore(
            initialState: MockData.makeState(breeds: [favorited], favorites: [favorited])
        ) {
            BreedListReducer()
        }

        await store.send(.breeds(.element(id: favorited.id, action: .favoriteButtonTapped))) {
            $0.$favoriteBreeds.withLock { $0.removeAll() }
        }
    }
}
