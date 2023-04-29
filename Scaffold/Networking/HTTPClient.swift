//
// Created by Michael Pace on 4/23/23.
//

import Foundation

protocol HTTPClient {
    func get<T: Decodable>(url: URL) async -> Result<T, NetworkError>
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

    func get<T: Decodable>(url: URL) async -> Result<T, NetworkError> {
        var decoded: T?
        do {
            let (data, response) = try await urlSession.data(from: url, delegate: nil)

            guard let httpReponse = response as? HTTPURLResponse else {
                throw NetworkError.internalError
            }

            guard !(400...499).contains(httpReponse.statusCode)
                && !(500...599).contains(httpReponse.statusCode) else {
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
