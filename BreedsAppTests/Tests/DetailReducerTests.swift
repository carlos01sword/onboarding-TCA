import Testing
import ComposableArchitecture
@testable import Breeds
import SwiftUI

@Suite("Detail Feature – Favorite Functionality")
@MainActor
struct DetailFeatureFavoriteFunctionalityTests {
    @Test
    func testTogglingFavorite() async {
        let breed = MockData.breed1
        let listState = MockData.makeState(favorites: [breed])
        let sharedFavorites = listState.$favoriteBreeds
        let store = TestStore(
            initialState: DetailReducer.State(
                cell: BreedCellReducer.State(
                    breed: breed,
                    favoriteBreeds: sharedFavorites
                )
            )
        ) { DetailReducer() }

        await store.send(.cell(.favoriteButtonTapped)) {
            $0.cell.$favoriteBreeds.withLock { favorites in
                _ = favorites.remove(id: breed.id)
            }
        }

        await store.send(.cell(.favoriteButtonTapped)) {
            $0.cell.$favoriteBreeds.withLock { favorites in
                favorites.append(breed)
            }
        }
    }

    @Test
    func testImageFetchingSuccess() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())
        let mockImage = UIImage(systemName: "photo")!
        let store = TestStore(
            initialState: DetailReducer.State(
                cell: BreedCellReducer.State(
                    breed: breed,
                    favoriteBreeds: sharedFavorites
                )
            )
        ) { DetailReducer() }

        store.dependencies.imageClient.fetchImage = { _ in mockImage }

        await store.send(.cell(.fetchImage)) {
            $0.cell.isLoadingImage = true
        }
        await store.receive(.cell(.imageResponse(TaskResult<UIImage>.success(mockImage)))) {
            $0.cell.isLoadingImage = false
            $0.cell.image = mockImage
        }
    }

    @Test
    func testImageFetchingFailure() async {
        let breed = MockData.breed1
        let sharedFavorites = Shared(value: IdentifiedArrayOf<Breed>())
        let store = TestStore(
            initialState: DetailReducer.State(
                cell: BreedCellReducer.State(
                    breed: breed,
                    favoriteBreeds: sharedFavorites
                )
            )
        ) { DetailReducer() }

        store.dependencies.imageClient.fetchImage = { _ in
            throw MockData.TestError()
        }

        await store.send(.cell(.fetchImage)) {
            $0.cell.isLoadingImage = true
        }
        await store.receive(.cell(.imageResponse(TaskResult<UIImage>.failure(MockData.TestError())))) {
            $0.cell.isLoadingImage = false
            $0.cell.image = nil
        }
    }
}
