import ComposableArchitecture
import Foundation

struct BreedsClient {
    var fetchBreeds: @Sendable (_ page: Int, _ limit: Int) async throws -> [Breed]
}

extension BreedsClient: DependencyKey {
    static let liveValue = BreedsClient { page, limit in
        do {
            let data = try await NetworkClient.fetch(.breeds(limit: limit, page: page))
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return (try decoder.decode([BreedDTO].self, from: data)).map(\.breed)
            } catch {
                throw NetworkError.decoding(error)
            }
        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            } else {
                throw NetworkError.transport(error)
            }
        }
    }
}

extension BreedsClient: TestDependencyKey {
    static let testValue = Self (
        fetchBreeds: { _, _ in
            [] }
    )
}

extension DependencyValues {
    var breedsClient: BreedsClient {
        get { self[BreedsClient.self] }
        set { self[BreedsClient.self] = newValue }
    }
}
