//
//  MockJSONDecoder.swift
//  ScaffoldTests
//
//  Created by Michael Pace on 4/27/23.
//

import Foundation

@testable import Scaffold

class MockJSONEncoder<T: Encodable>: ScaffoldJSONEncoder {
    var nextData: Data?
    var encodeInvocations = 0

    func encode<T>(_ value: T) throws -> Data where T: Encodable {
        encodeInvocations += 1

        guard let nextData = nextData else {
            throw NSError(domain: "MockJSONEncoder.nextData is nil", code: -1)
        }

        return nextData
    }
}
