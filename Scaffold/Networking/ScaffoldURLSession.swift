//
// Created by Michael Pace on 4/29/23.
//

import Foundation

protocol ScaffoldURLSession {
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse)
}

extension URLSession: ScaffoldURLSession {}
