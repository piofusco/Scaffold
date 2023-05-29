//
// Created by Michael Pace on 4/23/23.
//

import Foundation

protocol HTTPClient {
    func get<T: Decodable>(
        _ urlString: String,
        _ queryParameters: [String: String]
    ) async -> Result<T, Error>
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

    func get<T: Decodable>(
        _ urlString: String,
        _ queryParameters: [String: String] = [:]
    ) async -> Result<T, Error> {
        guard let _ = URL(string: urlString),
              var urlComponents = URLComponents(string: urlString) else {
            return Result.failure(NetworkError.internalError)
        }

        if !queryParameters.isEmpty {
            var queryItems = [URLQueryItem]()
            for (key, value) in queryParameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else {
            return Result.failure(NetworkError.internalError)
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

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
