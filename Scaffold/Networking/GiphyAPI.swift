//
// Created by Michael Pace on 4/29/23.
//

import Foundation

protocol API: AnyObject {
    func search(term: String, offset: Int) async -> Result<PageResponse, Error>
}

class GiphyAPI: API {
    private let httpClient: HTTPClient

    init(
        httpClient: HTTPClient
    ) {
        self.httpClient = httpClient
    }

    func search(term: String, offset: Int) async -> Result<PageResponse, Error> {
        guard !term.isEmpty else {
            return Result.failure(NetworkError.invalidParameters)
        }

        let parameters = [
            "offset": "\(offset)",
            "q": term,
        ]

        return await httpClient.request(url: .search, method: .get, parameters)
    }
}
