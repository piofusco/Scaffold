//
// Created by Michael Pace on 4/29/23.
//

import Foundation

enum GiphyURL: String {
    case search = "/v1/gifs/search"

    var urlString: String {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.giphy.com"
        urlComponents.path = self.rawValue

        switch self {
        case .search:
            urlComponents.queryItems?.append(URLQueryItem(name: "api_key", value: "WbLCO29ThDnFiB4rxeihH3BSx4vsVjBk"))
            urlComponents.queryItems?.append(URLQueryItem(name: "rating", value: "G"))
            urlComponents.queryItems?.append(URLQueryItem(name: "lang", value: "en"))
        }

        // TODO: figure out how to bubble up invalid URLs
        return urlComponents.url?.absoluteString ?? ""
    }
}