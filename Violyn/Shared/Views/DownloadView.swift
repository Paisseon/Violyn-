//
//  DownloadView.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import SwiftUI

struct DownloadView: View {
    @StateObject var vc = ViolynController.shared
    
    @State private var package = ""
    @State private var version = ""
    
    var body: some View {
        VStack {
            TextField("Bundle ID", text: $package)
                .modifier(LiteralEntry())
                .padding([.leading, .bottom, .trailing])
            
            TextField("Version", text: $version)
                .modifier(LiteralEntry())
                .padding()
            
            Button(action: {
                if package == "" || version == "" || vc.isHolding {
                    return
                }
                
                vc.download(package, version)
            }) {
                if vc.isHolding {
                    ProgressView()
                } else {
                    if vc.isSuccess {
                        Text("Success!")
                    } else {
                        Text(vc.error != "" ? vc.error : "Download")
                    }
                }
            }
                .opacity(package == "" || version == "" || vc.isHolding ? 0.6 : 1.0)
                .buttonStyle(ProgressStyle())
                .padding()
        }
    }
}
