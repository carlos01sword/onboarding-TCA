import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search Breeds"

    var body: some View {
        HStack(spacing: ConstantsUI.smallPadding) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)

            if !text.isEmpty {
                Button {
                    withAnimation(.easeInOut) {
                        text = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, ConstantsUI.smallPadding) 
        .frame(height: .searchBarHeight)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: .searchBarCornerRadius)
            .fill(Color(.systemGray6))
            .shadow())
        .animation(.easeInOut(duration: .animationSearchDuration), value: text)
        .padding(.horizontal)
    }
}

private extension CGFloat {
   static let searchBarCornerRadius: Self = 18
   static let searchBarHeight: Self = 36
}

private extension Double {
    static let animationSearchDuration: Self = 0.15
}

#if DEBUG
#Preview {
    @Previewable @State var text = ""
    let placeholder = "Search"
    return SearchBar(text: $text, placeholder: placeholder)
}
#endif
