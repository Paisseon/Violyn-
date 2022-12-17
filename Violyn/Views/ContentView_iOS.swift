//
//  ContentView_iOS.swift
//  Violyn
//
//  Created by Lilliana on 08/12/2022.
//

import SwiftUI

struct ContentView_iOS: View {
    @StateObject private var cypwn: CyPwn = .shared
    
    var body: some View {
        TabView {
            DownloadView()
                .tabItem {
                    Label("Download", systemImage: "square.and.arrow.down")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}
