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

@Suite("Breed List Feature - Search Functionality")
@MainActor
struct SearchFunctionalityTests {
    @Test
    func testSearchBreedNoMatch() async throws {
        let store = TestStore(initialState: MockData.makeState()) { BreedListReducer() }

        await store.send(.binding(.set(\.searchQuery, "CAT MEOW MEOW DOESNT EXIST"))) {
            $0.searchQuery = "CAT MEOW MEOW DOESNT EXIST"
        }
        #expect(store.state.filteredBreeds.isEmpty)
    }
    @Test
    func testSearchBreedWithMatch() async throws {
        let breed = MockData.breed1
        let store = TestStore(
            initialState: MockData.makeState(breeds: [breed])
        ) { BreedListReducer() }

        await store.send(.binding(.set(\.searchQuery,("Breed 1")))) {
            $0.searchQuery = "Breed 1"
        }

        #expect(store.state.filteredBreeds.count == 1)
        #expect(store.state.filteredBreeds.first?.id == breed.id)
    }

    @Test
    func testSearchBreedMultipleWordsWithMatch() async throws {
        let store = TestStore(
            initialState: MockData.makeState(
                breeds: [MockData.breed1, MockData.breed2]
            )
        ) { BreedListReducer() }

        await store.send(.binding(.set(\.searchQuery,("breed")))) {
            $0.searchQuery = "breed"
        }

        #expect(store.state.filteredBreeds.count == 2)
        #expect(store.state.filteredBreeds == store.state.breeds)
    }
}
