//
//  ViolynApp.swift
//  Shared
//
//  Created by Lilliana on 14/09/2022.
//

import SwiftUI

@main
struct ViolynApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, DataController.shared.persistentContainer.viewContext)
        }
    }
}
