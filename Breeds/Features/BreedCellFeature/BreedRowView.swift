import ComposableArchitecture
import SwiftUI

struct BreedRowView: View {

    let store: StoreOf<BreedCellReducer>

    var body: some View {
        HStack(spacing: .rowSpacing) {
            ImageCardView(id: store.breed.referenceImageID, isLoading: store.isLoadingImage, image: store.image)
                .foregroundColor(.gray.opacity(ConstantsUI.darkerOpacity))
                .scaledToFill()
                .frame(width: .imageRowFrameSize , height: .imageRowFrameSize)
                .clipShape(RoundedRectangle(cornerRadius: .imageRowCornerRadius))

            Text(store.breed.name)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()
            Button(action: { store.send(.favoriteButtonTapped) }){
                Image(systemName: store.isFavorite ? "star.fill" : "star")
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: .rowCornerRadius)
                .fill(Color(.systemBackground))
                .shadow()
        )
        .onAppear {
            store.send(.fetchImage)
        }
    }
}

private extension CGFloat {
    static let rowSpacing: Self = 16
    static let rowCornerRadius: Self = 16
    static let imageRowCornerRadius: Self = 8
    static let imageRowFrameSize: Self = 60
}

#if DEBUG
#Preview("Interactive Favorite Toggle") {
    BreedRowView(
        store: Store(
            initialState: BreedCellReducer.State(
                breed: MockData.sampleBreed,
                favoriteBreeds: Shared(value: IdentifiedArray(uniqueElements: [] as [Breed]))
            ),
            reducer: { BreedCellReducer() }
        )
    )
    .padding()
}
#endif
