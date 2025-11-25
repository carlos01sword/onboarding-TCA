import ComposableArchitecture
import SwiftUI

struct FavoriteView: View {
    @Bindable var store: StoreOf<FavoriteReducer>

    var body: some View {
        NavigationStack {
            if store.favoriteBreeds.isEmpty {
                FavoriteEmptyStateView()
            }
            else {
                ScrollView {
                    LazyVStack {
                        ForEach(store.favoriteBreeds) { breed in
                            Button {
                                store.send(.breedTapped(breed))
                            } label: {
                                BreedRowView(
                                    store: Store(
                                        initialState: BreedCellReducer.State(
                                            breed: breed,
                                            favoriteBreeds: store.$favoriteBreeds
                                        ),
                                        reducer: { BreedCellReducer() }
                                    )
                                )
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .padding(.horizontal)
                    .padding(.vertical, ConstantsUI.defaultVerticalSpacing)
                }
                .navigationTitle("⭐ Favorites")
                .navigationDestination(
                    item: Binding(
                        get: { store.detail?.cell.breed },
                        set: { _ in store.send(.dismissDetail) }
                    )
                ) { _ in
                    if let detailStore = store.scope(state: \.detail, action: \.detail) {
                        DetailView( store: detailStore )
                    }
                }
            }
        }
    }
}

#if DEBUG
    #Preview {
        FavoriteView(
            store: Store(initialState: FavoriteReducer.State(
                favoriteBreeds: Shared(value: IdentifiedArray(uniqueElements: [] as [Breed]))
            )) {
                FavoriteReducer()
            }
        )
    }
#endif
