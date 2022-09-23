//
//  RecentView.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import SwiftUI

struct RecentView: View {
    var body: some View {
        #if os(iOS)
            RecentViewiOS()
        #else
            RecentViewMac()
        #endif
    }
}
