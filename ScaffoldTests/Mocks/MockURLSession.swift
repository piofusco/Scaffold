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

    var lastURLFromData = [URL]()
    var nextResults = [(Data, URLResponse)]()

    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> (Data, URLResponse) {
        lastURLFromData.append(url)

        guard !nextResults.isEmpty else {
            throw NSError(domain: "MockURLSession.nextDataResults is empty", code: -1)
        }

        return nextResults.removeFirst()
    }
}
