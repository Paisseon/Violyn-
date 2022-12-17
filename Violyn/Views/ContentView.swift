//
//  ContentView.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            #if os(iOS)
            ContentView_iOS()
            #else
            ContentView_macOS()
            #endif
            
            LoadingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
