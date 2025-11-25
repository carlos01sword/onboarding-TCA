import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListReducer {

    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<BreedCellReducer.State> = []
        var isLoading: Bool = false
        var errorMessage: String?
        var detail: DetailReducer.State?
        var currentPage: Int = 0
        var canLoadMore: Bool = true

        @Presents var alert: AlertState<Action.Alert>?

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

        init(
            breeds: IdentifiedArrayOf<BreedCellReducer.State> = [],
            favoriteBreeds: Shared<IdentifiedArrayOf<Breed>> = Shared(.favoriteBreeds)
        ) {
            self.breeds = breeds
            self._favoriteBreeds = favoriteBreeds
        }
    }

    enum Action: Equatable {
        case alert(PresentationAction<Alert>)
        case breeds(IdentifiedAction<Breed.ID, BreedCellReducer.Action>)
        case breedsResponse(TaskResult<[Breed]>)
        case breedTapped(Breed)
        case detail(DetailReducer.Action)
        case dismissDetail
        case fetchBreeds
        case loadMore

        @CasePathable
        enum Alert: Equatable{}
    }

    @Dependency(\.breedsClient) var breedsClient

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {

            case .fetchBreeds:
                state.isLoading = true
                state.errorMessage = nil
                state.currentPage = 0
                state.canLoadMore = true

                return fetchBreeds(page: 0)

            case .loadMore:
                guard !state.isLoading, state.canLoadMore else { return .none }
                state.isLoading = true
                state.errorMessage = nil
                let nextPage = state.currentPage + 1

                return fetchBreeds(page: nextPage)

            case .breedsResponse(.success(let breeds)):
                state.isLoading = false
                state.canLoadMore = !breeds.isEmpty

                let newItems = breeds.map { BreedCellReducer.State(
                    breed: $0,
                    favoriteBreeds: state.$favoriteBreeds)
                }

                if state.currentPage == 0 {
                    state.breeds = IdentifiedArray(uniqueElements: newItems)
                } else {
                    state.breeds.append(contentsOf: newItems)
                }

                state.currentPage += 1
                return .none

            case .breedsResponse(.failure(let error)):
                state.isLoading = false
                let errorDescription = (error as? NetworkError)?.description ?? error.localizedDescription

                if state.breeds.isEmpty {
                    state.errorMessage = errorDescription
                    state.canLoadMore = false
                    return .none
                }

                state.canLoadMore = false
                state.alert = AlertState {
                    TextState("Network Error")
                } message: {
                    TextState("Could not load more breeds. Please check your connection.")
                }
                return .none

            case .breedTapped(let breed):
                guard let existingCellState = state.breeds[id: breed.id] else {
                    return .none
                }
                state.detail = DetailReducer.State(cell: existingCellState)
                return .none

            case .dismissDetail:
                state.detail = nil
                return .none

            case .alert:
                return .none

            case .breeds, .detail:
                return .none
            }
        }
        .forEach(\.breeds, action: \.breeds) { BreedCellReducer() }
        .ifLet(\.detail, action: \.detail) { DetailReducer() }
        .ifLet(\.alert, action: \.alert)
    }

    private func fetchBreeds(page: Int) -> Effect<Action> {
        .run { send in
            await send(
                .breedsResponse(
                    TaskResult { try await breedsClient.fetchBreeds(page, 10) }
                )
            )
        }
    }
}
