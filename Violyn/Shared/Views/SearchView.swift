//
//  SearchView.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        #if os(iOS)
            SearchViewiOS()
        #else
            SearchViewMac()
        #endif
    }
}