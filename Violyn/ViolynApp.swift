//
//  ViolynApp.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

import SwiftUI

@main
struct ViolynApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, DataManager.container.viewContext)
        }
    }
}
