//
//  MockJSONDecoder.swift
//  ScaffoldTests
//
//  Created by Michael Pace on 4/27/23.
//

import Foundation
import XCTest

@testable import Scaffold

class MockJSONDecoder<T: Decodable>: ScaffoldJSONDecoder {
    var nextDecodable: T?
    var decodeInvocations = 0

    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        decodeInvocations += 1

        guard let nextDecodable = nextDecodable as? T else {
            throw NSError(domain: "MockJSONDecoder.nextDecodable is nil", code: -1)
        }

        return nextDecodable
    }
}
