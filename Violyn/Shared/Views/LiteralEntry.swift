//
//  LiteralEntry.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import SwiftUI

struct LiteralEntry: ViewModifier {
    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .disableAutocorrection(true)
    }
}
