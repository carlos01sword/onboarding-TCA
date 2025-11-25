import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case invalidURL
    case badStatus(Int)
    case decoding(Error)
    case transport(Error)

    var description: String {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .badStatus(let code): return "Bad status code: \(code)"
        case .decoding(let err): return "Decoding error: \(err.localizedDescription)"
        case .transport(let err): return "Network error: \(err.localizedDescription)"
        }
    }
}

struct Endpoint {
    let path: String
    var queryItems: [URLQueryItem] = []
    var fetchBreedsUrl: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Environment.urlHost
        components.path = "/v1" + path
        components.queryItems = queryItems
        return components.url
    }
    var fetchImageUrl: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = Environment.urlHost
        components.path = "/v1/images/" + path
        return components.url
    }
}

extension Endpoint {
    static func breeds(limit: Int = 10, page: Int = 0) -> Endpoint {
        Endpoint(
            path: Environment.urlPath,
            queryItems: [
                URLQueryItem(name: "limit", value: "\(limit)"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
        )
    }

    static func image(id: String) -> Endpoint {
        Endpoint(path: id)
    }
}

struct NetworkClient {
    static func fetch(_ endpoint: Endpoint, isImage: Bool = false) async throws -> Data {
        let url = isImage ? endpoint.fetchImageUrl : endpoint.fetchBreedsUrl
        guard let url = url else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue(Environment.apiKey, forHTTPHeaderField: "x-api-key")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                throw NetworkError.badStatus(http.statusCode)
            }
            return data
        } catch {
            throw NetworkError.transport(error)
        }
    }
}
