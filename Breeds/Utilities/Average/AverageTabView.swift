import ComposableArchitecture
import SwiftUI

struct AverageTabView: View {

    var breeds: IdentifiedArrayOf<Breed>

    var body: some View {
        if !breeds.isEmpty {
            let averageLifeSpan = AverageHelper.averageLifeSpan(from: breeds)

            Text("Average Life Span: \(averageLifeSpan)")
                .font(.subheadline)
                .padding(.horizontal)
                .frame(height: .averageTabViewHeight)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: .averageTabViewCornerRadius)
                        .fill(Color(.systemGray6))
                        .shadow()
                        .padding(.horizontal)
                )
        }
    }
}

private extension CGFloat {
   static let averageTabViewCornerRadius: Self = 18
   static let averageTabViewHeight: Self = 36
}

#if DEBUG
#Preview{
    AverageTabView(breeds: IdentifiedArray(uniqueElements: [MockData.sampleBreed] as [Breed]))
}
#endif
