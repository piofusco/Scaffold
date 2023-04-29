//
// Created by Michael Pace on 4/23/23.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
}

protocol HTTPClient {
    func request<T: Decodable>(
        url: GiphyURL,
        method: HTTPMethod,
        _ parameters: [String: String]
    ) async -> Result<T, NetworkError>
}

class DefaultHTTPClient: HTTPClient {
    private let urlSession: ScaffoldURLSession
    private let decoder: ScaffoldJSONDecoder

    init(
        urlSession: ScaffoldURLSession,
        decoder: ScaffoldJSONDecoder
    ) {
        self.urlSession = urlSession
        self.decoder = decoder
    }

    func request<T: Decodable>(url: GiphyURL, method: HTTPMethod, _ parameters: [String: String]) async -> Result<T, NetworkError> {
        let urlComponents = url.buildURLComponents(parameters)
        guard let url = urlComponents.url else {
            return Result.failure(NetworkError.badRequest)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        var decoded: T?
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.internalError
            }

            guard !(400...499).contains(httpResponse.statusCode)
                && !(500...599).contains(httpResponse.statusCode) else {
                return Result.failure(NetworkError.badRequest)
            }

            decoded = try decoder.decode(T.self, from: data)
        } catch {
            print(error)
            return Result.failure(NetworkError.invalidJSON)
        }

        guard let decoded else {
            return Result.failure(NetworkError.internalError)
        }

        return Result.success(decoded)
    }
}
