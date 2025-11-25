import ComposableArchitecture
import SwiftUI
@Reducer
struct FavoriteReducer {
    @ObservableState
    struct State: Equatable {
        var detail: DetailReducer.State?
        @ObservationStateIgnored
        @Shared(.favoriteBreeds) var favoriteBreeds
    }

    enum Action: Equatable {
        case breedTapped(Breed)
        case dismissDetail
        case detail(DetailReducer.Action)
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .breedTapped(let breed):
                state.detail = DetailReducer.State(
                    cell: BreedCellReducer.State(
                        breed: breed,
                        favoriteBreeds: state.$favoriteBreeds))
                return .none

            case .dismissDetail:
                state.detail = nil
                return .none

            case .detail:
                return .none
            }
        }
        .ifLet(\.detail, action: \.detail) { DetailReducer() }
    }
}
