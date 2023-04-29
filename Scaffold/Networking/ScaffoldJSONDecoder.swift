//
//  ScaffoldJSONDecoder.swift
//  Scaffold
//
//  Created by Michael Pace on 4/27/23.
//

import Foundation

protocol ScaffoldJSONDecoder {
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable
}

extension JSONDecoder: ScaffoldJSONDecoder {}
