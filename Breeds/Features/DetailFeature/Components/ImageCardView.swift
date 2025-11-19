import SwiftUI

struct ImageCardView: View {
    let id: String?
    let isLoading: Bool
    let image: UIImage?

    var body: some View {
        Group {
            if let image {
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
        isLoading: false,
        image: UIImage(systemName: "pawprint.fill")
    )
    .frame(width: 300, height: 300)
    .cardImageStyle()
}
#endif
