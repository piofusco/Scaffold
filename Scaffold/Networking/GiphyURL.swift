//
// Created by Michael Pace on 4/29/23.
//

import Foundation

enum GiphyURL: String {
    case search = "/v1/gifs/search"

    // TODO: ensure parameters are URL encoded; default to empty string otherwise
    func buildURLComponents(_ parameters: [String: String]) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.giphy.com"
        urlComponents.path = self.rawValue
        urlComponents.queryItems = defaultQueryParams(parameters)

        return urlComponents
    }

    private func defaultQueryParams(_ include: [String: String]) -> [URLQueryItem] {
        var queryItems = include
        switch self {
        case .search:
            queryItems["api_key"] = "WbLCO29ThDnFiB4rxeihH3BSx4vsVjBk" // TODO: obfuscate this somehow...
            queryItems["rating"] = "G"
            queryItems["lang"] = "en"
        }

        var result = [URLQueryItem]()
        for (key, value) in queryItems {
            result.append(URLQueryItem(name: key, value: value))
        }
        return result
    }
}