import ComposableArchitecture
import Foundation

struct AverageHelper {
    static func averageLifeSpan(from breeds: IdentifiedArrayOf<Breed>) -> Int {

        guard !breeds.isEmpty else {
            return 0
        }

        let maxValues = breeds.compactMap { breed -> Int? in
            let values = breed.lifeSpan
                .split(separator: "-")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            if let max = values.last, let maxInt = Int(max) {
                return maxInt
            }
            return nil
        }

        guard !maxValues.isEmpty else {
            return 0
        }

        let total = maxValues.reduce(0, +)
        return total / maxValues.count
    }
}
