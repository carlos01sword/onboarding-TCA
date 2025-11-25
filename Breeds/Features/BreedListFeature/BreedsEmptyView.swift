import SwiftUI

struct BreedsEmptyView: View {
    var body: some View {
        VStack(spacing: ConstantsUI.defaultVerticalSpacing) {
            Image(systemName: "wifi.slash")
                .font(.system(size: ConstantsUI.emptyStateIconSize))
                .foregroundStyle(.secondary)
            Text("Please Check Your Internet Connection")
                .font(.headline)
                .foregroundStyle(.primary)
        }
        .multilineTextAlignment(.center)
        .padding(ConstantsUI.largeVerticalSpacing)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#if DEBUG
#Preview {
    BreedsEmptyView()
}
#endif
