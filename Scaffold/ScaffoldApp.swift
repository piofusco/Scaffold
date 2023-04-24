//
//  ScaffoldApp.swift
//  Scaffold
//
//  Created by Michael Pace on 4/23/23.
//

import SwiftUI

struct ScaffoldApp: App {
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
                case .active: print("App state: active")
                case .background: print("App state: background")
                case .inactive: print("App state: inactive")
                @unknown default:
                    fatalError()
            }
        }
    }
}
