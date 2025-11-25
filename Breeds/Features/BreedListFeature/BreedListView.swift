import ComposableArchitecture
import SwiftUI

struct BreedListView: View {
    @Bindable var store: StoreOf<BreedListReducer>

    var body: some View {
        NavigationStack {
            ZStack {
                if store.breeds.isEmpty && store.isLoading {
                    ProgressView("Loading breeds...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if store.breeds.isEmpty{
                    BreedsEmptyView()
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEachStore(
                                self.store.scope(state: \.breeds, action: \.breeds)
                            ) { breedStore in
                                let breed = breedStore.state.breed
                                Button {
                                    store.send(.breedTapped(breed))
                                } label: {
                                    BreedRowView(store: breedStore)
                                }
                                .onAppear {
                                    if breed.id == store.breeds.last?.id {
                                        store.send(.loadMore)
                                    }
                                }
                            }
                            if store.isLoading && !store.breeds.isEmpty {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .contentShape(Rectangle())
                        .padding(.horizontal)
                        .padding(.vertical, ConstantsUI.defaultVerticalSpacing)
                    }
                }
            }
            .navigationTitle("🐈 Cat Breeds")
            .onAppear {
                if store.breeds.isEmpty {
                    store.send(.fetchBreeds)
                }
            }
            .navigationDestination(
                item: Binding(
                    get: { store.detail?.cell.breed },
                    set: { _ in store.send(.dismissDetail) }
                )
            ) { _ in
                if let detailStore = store.scope(state: \.detail, action: \.detail) {
                    DetailView(store: detailStore)
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
        }
    }
}

#if DEBUG
#Preview {
    BreedListView(
        store: Store(initialState: BreedListReducer.State(
            favoriteBreeds: Shared(value: IdentifiedArray(uniqueElements: [] as [Breed]))
        )) {
            BreedListReducer()
        }
    )
}
#endif
