//
//  AppLauncher.swift
//  Scaffold
//
//  Created by Michael Pace on 4/23/23.
//

import Foundation

@main
struct AppLauncher {

    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            ScaffoldApp.main()
        } else {
            TestApp.main()
        }
    }
}
