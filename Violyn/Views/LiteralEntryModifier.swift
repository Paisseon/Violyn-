//
//  LiteralEntryModifier.swift
//  Violyn
//
//  Created by Lilliana on 01/12/2022.
//

import SwiftUI

struct LiteralEntryModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 15, *) {
            content
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
        } else {
            content
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
        }
        #else
        content
            .textFieldStyle(.roundedBorder)
            .disableAutocorrection(true)
        #endif
    }
}
