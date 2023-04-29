//
//  MockURLSession.swift
//  ScaffoldTests
//
//  Created by Michael Pace on 4/27/23.
//

import Foundation
import XCTest

@testable import Scaffold

class MockURLSession: ScaffoldURLSession {
    var lastURLRequests = [URLRequest]()
    var lastHeaders: [String: String]?

    var nextResults = [(Data, URLResponse)]()

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastURLRequests.append(request)
        lastHeaders = request.allHTTPHeaderFields

        if nextResults.count > 0 {
            return nextResults.removeFirst()
        } else {
            throw NSError(domain: "MockURLSession.nextData is empty", code: -1)
        }
    }
}
