import Testing
import ComposableArchitecture
@testable import Breeds

@MainActor
struct AverageCalculationTests {

    @Test func testAverageLifeSpanCalculation() async throws {
        let breeds: IdentifiedArrayOf<Breed> = [
            Breed(id: "1", name: "", origin: "", temperament: "", description: "", lifeSpan: "10 - 15", referenceImageID: nil),
            Breed(id: "2", name: "", origin: "", temperament: "", description: "", lifeSpan: "8 - 12", referenceImageID: nil),
            Breed(id: "3", name: "", origin: "", temperament: "", description: "", lifeSpan: "12 - 18", referenceImageID: nil)
        ]

        let state = MockData.makeState(favorites: breeds.elements)

        let average = AverageHelper.averageLifeSpan(from: state.favoriteBreeds)
        // result: the average should be calculated from the maximum value of each life span range: (15 + 12 + 18) / 3 = 15
        #expect(average == 15)
    }

    @Test func testEmptyFavoritesAverageLifeSpan() async throws {
        let state = MockData.makeState(favorites: [])

        let average = AverageHelper.averageLifeSpan(from: state.favoriteBreeds)
        // No favorite breeds, the average should be 0
        #expect(average == 0)

    }
}
