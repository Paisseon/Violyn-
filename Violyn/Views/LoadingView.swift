//
//  LoadingView.swift
//  Violyn
//
//  Created by Lilliana on 09/12/2022.
//

import SwiftUI

// MARK: - LoadingView

struct LoadingView: View {
    // MARK: Internal

    @Environment(\.colorScheme) var currentMode

    var body: some View {
        ZStack {
            currentMode == .dark ? Color.black : Color.white

            Text("\nViolyn\n")
                .font(.custom("Modish-Regular", size: 50, relativeTo: .headline))
                .scaleEffect(isAnimating ? 1.25 : 1)
                .animation(.easeInOut(duration: 0.25))
                .onAppear {
                    isAnimating = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        isAnimating = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isAnimating = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        isAnimating = false
                        isShowing = false
                    }
                }
        }
        .opacity(isShowing ? 1 : 0)
    }

    // MARK: Private

    @State private var isShowing: Bool = true
    @State private var isAnimating: Bool = false
}
