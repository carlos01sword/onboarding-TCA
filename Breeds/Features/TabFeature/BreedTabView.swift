import ComposableArchitecture
import SwiftUI

struct BreedTabView: View {
    var store: StoreOf<BreedListReducer>
    var favoriteStore: StoreOf<FavoriteReducer>

    var body: some View {
        TabView {
            BreedListView(store: store)
                .tabItem {
                    Label("All", systemImage: "pawprint.fill")
                }

            FavoriteView(store: favoriteStore)
            .tabItem {
                Label("Favorites", systemImage: "star.fill")
            }
        }
    }
}

#if DEBUG
    #Preview {
        BreedTabView(
            store: Store(
                initialState: BreedListReducer.State(),
                reducer: { BreedListReducer() }
            ),
            favoriteStore: Store(
                initialState: FavoriteReducer.State(),
                reducer: { FavoriteReducer() }
            )
        )
    }
#endif
