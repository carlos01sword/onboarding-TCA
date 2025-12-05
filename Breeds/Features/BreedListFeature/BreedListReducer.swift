import SwiftUI
import ComposableArchitecture

@Reducer
struct BreedListReducer {

    @ObservableState
    struct State: Equatable {
        var breeds: IdentifiedArrayOf<BreedCellReducer.State> = []
        var isLoading: Bool = false
        var errorMessage: String?
        @Presents var detail: DetailReducer.State?
        var currentPage: Int = 0
        var canLoadMore: Bool = true
        var searchQuery: String = ""
        var hasBreeds: Bool { !breeds.isEmpty }
        var isLoadingPlaceholderVisible: Bool { breeds.isEmpty && isLoading }
        var isSearchEmptyStateVisible: Bool { filteredBreeds.isEmpty && !searchQuery.isEmpty }

        var filteredBreeds: IdentifiedArrayOf<BreedCellReducer.State> {
            breeds.filter {
                searchQuery.isEmpty || $0.breed.name.localizedCaseInsensitiveContains(searchQuery)
            }
        }


        @Presents var alert: AlertState<Action.Alert>?

        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds

    }

    enum Action: BindableAction, Equatable {

        enum View: Equatable {
            case onAppear
            case loadMoreTriggered
            case breedTapped(Breed.ID)
            case rowAppeared(Breed.ID)
        }

        enum Internal: Equatable {
            case fetchBreeds
            case breedsResponse(TaskResult<[Breed]>)
        }

        enum Delegate: Equatable {}

        case view(View)
        case `internal`(Internal)
        case delegate(Delegate)

        case binding(BindingAction<State>)
        case breeds(IdentifiedAction<Breed.ID, BreedCellReducer.Action>)
        case detail(PresentationAction<DetailReducer.Action>)
        case alert(PresentationAction<Alert>)

        @CasePathable
        enum Alert: Equatable {}
    }

    @Dependency(\.breedsClient) var breedsClient

    var body: some Reducer<State, Action> {

        BindingReducer()

        Reduce { state, action in
            switch action {

            case .view(let viewAction):
                switch viewAction {

                case .onAppear:
                    if state.breeds.isEmpty {
                        return .send(.internal(.fetchBreeds))
                    }
                    return .none

                case .loadMoreTriggered:
                    guard !state.isLoading, state.canLoadMore else { return .none }
                    state.isLoading = true
                    state.errorMessage = nil
                    let nextPage = state.currentPage + 1
                    return fetchBreeds(page: nextPage)

                case .breedTapped(let id):
                    guard let existingCellState = state.breeds[id: id] else { return .none }
                    state.detail = DetailReducer.State(cell: existingCellState)
                    return .none

                case .rowAppeared(let id):
                    guard state.searchQuery.isEmpty,
                          state.canLoadMore,
                          id == state.breeds.last?.id else { return .none }
                    return .send(.view(.loadMoreTriggered))
                }

            case .internal(let internalAction):
                switch internalAction {

                case .fetchBreeds:
                    state.isLoading = true
                    state.errorMessage = nil
                    state.currentPage = 0
                    state.canLoadMore = true

                    return fetchBreeds(page: 0)

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
                }

            case .breeds, .detail, .alert, .delegate, .binding:
                return .none

            }
        }
        .forEach(\.breeds, action: \.breeds) { BreedCellReducer() }
        .ifLet(\.$detail, action: \.detail) { DetailReducer() }
        .ifLet(\.alert, action: \.alert)
    }

    private func fetchBreeds(page: Int) -> Effect<Action> {
        .run { send in
            await send(
                .internal(.breedsResponse(
                    TaskResult { try await breedsClient.fetchBreeds(page, 10) }
                ))
            )
        }
    }
}
