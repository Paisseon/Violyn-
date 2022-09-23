//
//  ContentView.swift
//  Shared
//
//  Created by Lilliana on 14/09/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            ViolynHeaderView()
                .padding(.bottom, -50)
            
            TabView{
                DownloadView()
                    .tabItem({
                        Label("Download",
                              systemImage: "square.and.arrow.down")
                    })
                SearchView()
                    .tabItem({
                        Label("Search",
                              systemImage: "magnifyingglass")
                    })
                RecentView()
                    .tabItem({
                        Label("Recent",
                              systemImage: "clock")
                    })
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
