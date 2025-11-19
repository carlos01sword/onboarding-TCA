import SwiftUI

struct ImageCardView: View {
    let id: String?
    let isLoading: Bool

    var body: some View {
        Group {
            if let image = ImageCache.getSynchronously(for: id) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ProgressView()
            } else {
                Image(systemName: "pawprint.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
    }
}

#if DEBUG
#Preview {
    ImageCardView(
        id: MockData.sampleBreed.referenceImageID,
        isLoading: false
    )
    .frame(width: 300, height: 300)
    .cardImageStyle()
}
#endif
