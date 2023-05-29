//
//  ScaffoldJSONDecoder.swift
//  Scaffold
//
//  Created by Michael Pace on 4/27/23.
//

import Foundation

protocol ScaffoldJSONEncoder {
    func encode<T>(_ value: T) throws -> Data where T : Encodable
}

extension JSONEncoder: ScaffoldJSONEncoder {}
