//
//  ViolynHeaderView.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import SwiftUI

struct ViolynHeaderView: View {
    var body: some View {
        
        /// Show "Violyn" in a multicolour, animated text view above each tab
        
        ColorfulView()
            .frame(height: 200, alignment: .center)
            .mask(
                Text("\nViolyn\n")
                    .font(.custom("Modish-Regular", size: 62, relativeTo: .headline))
            )
    }
}
