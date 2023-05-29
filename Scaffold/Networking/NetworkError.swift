//
// Created by Michael Pace on 4/29/23.
//

import Foundation

enum NetworkError: Error {
    case badURL
    case badRequest
    case internalError
    case invalidJSON
    case invalidParameters
    case internalServerError
}