import SwiftUI

struct InfoCardView: View {
        let breed: Breed

        var body: some View {
            VStack(alignment: .leading, spacing: ConstantsUI.largeVerticalSpacing) {

                Text("Curious Facts!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)

                InfoRow(label: "Origin", value: breed.origin)
                InfoRow(
                    label: "Life Span",
                    value: "\(breed.lifeSpan) years"
                )
                InfoRow(label: "Temperament", value: breed.temperament)
                InfoRow(label: "Description", value: breed.description)

            }
            .padding(.horizontal, ConstantsUI.defaultPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: ConstantsUI.extraSmallSpacing) {
            Text(label)
                .font(.headline)
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
    #Preview {
        InfoCardView(breed: MockData.sampleBreed)
    }
#endif
