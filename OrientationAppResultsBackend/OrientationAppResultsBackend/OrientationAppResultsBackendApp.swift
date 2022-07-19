//
//  OrientationAppResultsBackendApp.swift
//  OrientationAppResultsBackend
//
//  Created by Fiona Powers Beggs on 3/16/22.
//

import SwiftUI

@main
struct OrientationAppResultsBackendApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
