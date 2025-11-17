import ComposableArchitecture
import Foundation

struct AverageHelper: Codable, Equatable {
    static func averageLifeSpan(from breeds: IdentifiedArrayOf<Breed>) -> Int {

        guard !breeds.isEmpty else {
            return 0
        }

        var total: Int = 0
        var counter: Int = 0

        for breed in breeds {
            let values = breed.lifeSpan
                .split(separator: "-")
                .map { $0.trimmingCharacters(in: .whitespaces) }

            if let max = values.last,
               let maxInt = Int(max){
                total += maxInt
                counter += 1
            }
        }

        guard counter > 0 else {
            return 0
        }

        return total / counter
    }
}
