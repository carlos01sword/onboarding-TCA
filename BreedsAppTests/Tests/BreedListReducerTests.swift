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

        await store.send(.searchQueryChanged("CAT MEOW MEOW DOESNT EXIST")) {
            $0.searchQuery = "CAT MEOW MEOW DOESNT EXIST"
            $0.filteredBreeds = []
        }
    }
    @Test
    func testSearchBreedWithMatch() async throws {
        let breed = MockData.breed1
        let store = TestStore(
            initialState: MockData.makeState(breeds: [breed])
        ) { BreedListReducer() }

        await store.send(.searchQueryChanged("Breed 1")) {
            $0.searchQuery = "Breed 1"
            $0.filteredBreeds = IdentifiedArray(
                uniqueElements: [
                    BreedCellReducer.State(
                        breed: breed,
                        favoriteBreeds: $0.$favoriteBreeds
                    )
                ]
            )
        }
    }

    @Test
    func testSearchBreedMultipleWordsWithMatch() async throws {
        let store = TestStore(
            initialState: MockData.makeState(
                breeds: [MockData.breed1, MockData.breed2]
            )
        ) { BreedListReducer() }

        await store.send(.searchQueryChanged("breed")) {
            $0.searchQuery = "breed"
            $0.filteredBreeds = IdentifiedArray(
                uniqueElements: [
                    BreedCellReducer.State(
                        breed: MockData.breed1,
                        favoriteBreeds: $0.$favoriteBreeds
                    ),
                    BreedCellReducer.State(
                        breed: MockData.breed2,
                        favoriteBreeds: $0.$favoriteBreeds
                    )
                ]
            )
        }
    }

    @Test
    func testEmptyQuerySearch() async throws {
        let breeds = [MockData.breed1, MockData.breed2]
        let store = TestStore(initialState: MockData.makeState(breeds: breeds)) {
            BreedListReducer()
        }

        await store.send(.searchQueryChanged("")) {
            $0.searchQuery = ""
            $0.filteredBreeds = $0.breeds
        }
    }
}
