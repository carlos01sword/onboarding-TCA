import Testing
import ComposableArchitecture
@testable import Breeds

@Suite("Breed List Feature – Network Service")
@MainActor
struct NetworkServiceTests{

    @Test func fetchBreedsSuccess() async {
        let mockBreeds = [MockData.breed1, MockData.breed2]

        let store = TestStore(initialState: BreedListReducer.State()) {
            BreedListReducer()
        }

        store.dependencies.breedsClient.fetchBreeds = { _, _ in mockBreeds }

        await store.send(.fetchBreeds) {
            $0.isLoading = true
            $0.errorMessage = nil
            $0.currentPage = 0
            $0.canLoadMore = true
        }

        await store.receive(.breedsResponse(.success(mockBreeds))) { state in
            state.isLoading = false
            state.canLoadMore = true
            state.currentPage = 1

            state.breeds = IdentifiedArray(
                uniqueElements: mockBreeds.map { breed in
                    BreedCellReducer.State(
                        breed: breed,
                        favoriteBreeds: state.$favoriteBreeds
                    )
                }
            )
        }
    }

    @Test func fetchBreedsFailure() async {
        let error = MockData.TestError()

        let store = TestStore(initialState: BreedListReducer.State()) {
            BreedListReducer()
        }
        store.dependencies.breedsClient.fetchBreeds = { _, _ in throw error }

        await store.send(.fetchBreeds) {
            $0.isLoading = true
            $0.errorMessage = nil
            $0.currentPage = 0
            $0.canLoadMore = true
        }

        await store.receive(.breedsResponse(.failure(error))) {
            $0.isLoading = false
            $0.errorMessage = error.errorDescription
            $0.canLoadMore = false
        }
    }
}
