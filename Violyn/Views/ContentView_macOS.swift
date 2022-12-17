//
//  ContentView_macOS.swift
//  Violyn
//
//  Created by Lilliana on 08/12/2022.
//

import SwiftUI

struct ContentView_macOS: View {
    @StateObject private var cypwn: CyPwn = .shared
    @State private var selected: Int? = 0
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                List {
                    NavigationLink(destination: DownloadView(), tag: 0, selection: $selected) {
                        Label("Download", systemImage: "square.and.arrow.down")
                    }
                    .padding()
                    
                    NavigationLink(destination: SearchView(), tag: 3, selection: $selected) {
                        Label("Search", systemImage: "magnifyingglass")
                    }
                    .padding()
                }
                .listStyle(SidebarListStyle())
            }
        }
    }
}
