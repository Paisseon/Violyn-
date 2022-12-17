//
//  DownloadView.swift
//  Violyn
//
//  Created by Lilliana on 01/12/2022.
//

import CommonCrypto
import SwiftUI

struct DownloadView: View {
    // MARK: Internal

    var body: some View {
        VStack {
            TextField("Bundle ID", text: $package)
                .modifier(LiteralEntryModifier())
                .padding()
            
            TextField("Version", text: $version)
                .modifier(LiteralEntryModifier())
                .padding()
            
            TaskButtonView(title: "Download", icon: "square.and.arrow.down") {
                Task {
                    do {
                        let result: DownloadResult = try await Downloader.download(package, version)
                        await Progress.shared.setLabel(result.description)
                        
                        if progress.finished >= progress.current {
                            await Progress.shared.clear()
                        }
                    } catch {
                        await progress.setLabel(error.localizedDescription)
                        await progress.clear()
                    }
                }
            }
            
            Text("Created by CyPwn")
            .opacity(0.1)
        }
    }

    // MARK: Private

    @StateObject private var progress: Progress = .shared
    
    @State private var package: String = ""
    @State private var version: String = ""
}
