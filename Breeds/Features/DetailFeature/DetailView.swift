import ComposableArchitecture
import SwiftUI

struct DetailView: View {

    @Bindable var store: StoreOf<DetailReducer>

    var body: some View{
        NavigationStack{
            ScrollView {
                VStack(spacing: ConstantsUI.largeVerticalSpacing) {

                    Text(store.cell.breed.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    ImageCardView(id: store.cell.breed.referenceImageID, isLoading: store.cell.isLoadingImage, image: store.cell.image)
                    .cardImageStyle()

                    InfoCardView(breed: store.cell.breed)

                    Button {
                        store.send(.cell(.favoriteButtonTapped))
                    } label: {
                        Text(store.cell.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                            .favoritesButtonStyle()
                    }
                }
                .padding(.bottom, ConstantsUI.defaultPadding)
            }
            .toolbar(.hidden, for: .tabBar)
            .onAppear {
                store.send(.cell(.fetchImage))
            }
        }
    }
}


#if DEBUG
#Preview{
    DetailView(
        store: StoreOf<DetailReducer>(
            initialState: DetailReducer.State(
                cell: BreedCellReducer.State(
                    breed: MockData.sampleBreed,
                    favoriteBreeds: Shared(value: IdentifiedArray(uniqueElements: [] as [Breed]))
                )
            ),
            reducer: { DetailReducer() }
        )
    )
}
#endif
