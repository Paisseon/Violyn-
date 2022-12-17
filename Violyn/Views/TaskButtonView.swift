//
//  TaskButtonView.swift
//  Violyn
//
//  Created by Lilliana on 08/12/2022.
//

import SwiftUI

struct TaskButtonView: View {
    @StateObject private var progress: Progress = .shared
    
    var title: String
    var icon: String
    var colour: Color = .accentColor
    var task: () -> Void

    var body: some View {
        Label(title: {
            Text(progress.label ?? title)
                .fontWeight(.semibold)
        }, icon: {
            Image(systemName: icon)
        })
        .foregroundColor(.white)
        .frame(minWidth: 150.0, minHeight: 64.0)
        .background(
            GeometryReader { geo in
                colour.opacity(0.5)
                colour.frame(width: progress.current == 0 ? geo.size.width : (geo.size.width * (progress.finished / progress.current)))
                    .animation(.easeIn)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .padding()
        .onTapGesture(perform: task)
    }
}
