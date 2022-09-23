//
//  ProgressStyle.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import SwiftUI

import SwiftUI

struct ProgressStyle: ButtonStyle {
    @StateObject var vc = ViolynController.shared
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0,maxWidth: .infinity)
            .foregroundColor(Color.white)
            .padding()
            .background(
                GeometryReader { geo in
                    if vc.error == "" {
                        Color.accentColor
                            .opacity(0.5)
                        Color.accentColor
                            .frame(width: geo.size.width * vc.progress)
                            .animation(.easeIn)
                    } else {
                        Color.red
                            .opacity(0.5)
                        Color.red
                            .frame(width: geo.size.width * vc.progress)
                            .animation(.easeIn)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
            .padding()
            .scaleEffect(1.0)
    }
}
