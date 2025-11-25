import SwiftUI

struct FavoriteEmptyStateView: View {
    var body: some View {
        VStack(spacing: ConstantsUI.defaultVerticalSpacing) {
            Image(systemName: "star")
                .font(.system(size: ConstantsUI.emptyStateIconSize))
                .foregroundStyle(.secondary)
            Text("No favorites yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Tap the star on a breed to add it here.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .accessibilityElement(children: .combine)
    }
}
#if DEBUG
#Preview {
    FavoriteEmptyStateView()
}
#endif
