import ComposableArchitecture
import SwiftUI

struct BreedListView: View {
    @Bindable var store: StoreOf<BreedListReducer>
    
    var body: some View {
        NavigationStack {
            VStack {
                if !store.breeds.isEmpty {
                    SearchBar(text: $store.searchQuery)
                    .padding(.bottom, ConstantsUI.defaultVerticalSpacing)
                }
                
                ZStack {
                    if store.breeds.isEmpty && store.isLoading {
                        ProgressView("Loading breeds...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    } else if store.breeds.isEmpty {
                        BreedsEmptyView()
                        
                    } else if store.filteredBreeds.isEmpty && !store.searchQuery.isEmpty {
                        SearchEmptyStateView(searchText: store.searchQuery)
                        
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(store.filteredBreeds.ids, id: \.self) { id in
                                    if let childStore = store.scope(state: \.breeds[id: id], action: \.breeds[id: id]) {
                                        
                                        BreedRowView(store: childStore)
                                            .onTapGesture {
                                                store.send(.breedTapped(childStore.state.breed))
                                            }
                                            .onAppear {
                                                if store.searchQuery.isEmpty && id == store.breeds.last?.id {
                                                    store.send(.loadMore)
                                                }
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
                            .padding(.bottom, ConstantsUI.defaultVerticalSpacing)
                        }
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
                item: $store.scope(state: \.detail, action: \.detail)
            ) { detailStore in
                DetailView(store: detailStore)
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
