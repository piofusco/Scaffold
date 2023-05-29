//
// Created by Michael Pace on 4/23/23.
//

import Foundation

protocol HTTPClient {
    func get<T: Decodable>(
        _ urlString: String,
        _ queryParameters: [String: String]
    ) async -> Result<T, Error>

    func post<T: Decodable>(
        _ urlString: String,
        _ queryParameters: [String: String],
        _ body: Encodable?
    ) async -> Result<T, Error>
}

class DefaultHTTPClient: HTTPClient {
    private let urlSession: ScaffoldURLSession
    private let decoder: ScaffoldJSONDecoder
    private let encoder: ScaffoldJSONEncoder

    init(
        urlSession: ScaffoldURLSession,
        decoder: ScaffoldJSONDecoder,
        encoder: ScaffoldJSONEncoder
    ) {
        self.urlSession = urlSession
        self.decoder = decoder
        self.encoder = encoder
    }

    func get<T: Decodable>(
        _ urlString: String,
        _ queryParameters: [String: String] = [:]
    ) async -> Result<T, Error> {
        guard let _ = URL(string: urlString),
              var urlComponents = URLComponents(string: urlString) else {
            return Result.failure(NetworkError.badURL)
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

            guard !(400...499).contains(httpResponse.statusCode) else {
                return Result.failure(NetworkError.badRequest)
            }

            guard !(500...599).contains(httpResponse.statusCode) else {
                return Result.failure(NetworkError.internalServerError)
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

    func post<T: Decodable>(
        _ urlString: String,
        _ queryParameters: [String: String] = [:],
        _ body: Encodable? = nil
    ) async -> Result<T, Error> {
        guard let _ = URL(string: urlString),
              var urlComponents = URLComponents(string: urlString),
              let body else {
            return Result.failure(NetworkError.internalError)
        }

        var data: Data?
        do {
            data = try encoder.encode(body)
        } catch {
            print(error)
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
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = data
        var decoded: T?
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.internalError
            }

            guard !(400...499).contains(httpResponse.statusCode) else {
                return Result.failure(NetworkError.badRequest)
            }

            guard !(500...599).contains(httpResponse.statusCode) else {
                return Result.failure(NetworkError.internalServerError)
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
