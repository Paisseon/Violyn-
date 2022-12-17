//
//  InfoView.swift
//  Violyn
//
//  Created by Lilliana on 10/12/2022.
//

import SwiftUI

struct InfoView: View {
    // MARK: Internal

    @State var entity: Entity
    @State private var isSelected: Bool = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(entity.name ?? "null_v0.0")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    isSelected.toggle()
                }
            Spacer()
            Text(prettySize(for: entity.size))
                .padding(.trailing)
            Text(prettyDate(for: entity.date))
                .padding([.leading, .trailing])
            
            if isSelected {
                Button("Download") {
                    Task {
                        do {
                            let entName: String = entity.name ?? "null_v0.0"
                            let package: String = entName.components(separatedBy: "_v").first!
                            let version: String = entName.components(separatedBy: "_v").last!
                            let result: DownloadResult = try await Downloader.download(package, version)
                            
                            await Progress.shared.setLabel(result.description)
                        } catch {
                            await Progress.shared.setLabel(error.localizedDescription)
                            await Progress.shared.clear()
                        }
                    }
                }
            }
        }
    }

    // MARK: Private

    private func prettySize(
        for size: Int64
    ) -> String {
        if size >= 1024 * 1024 {
            let sizeInMB = Double(size) / 1024.0 / 1024.0
            return String(format: "%.1f mb", sizeInMB)
        } else {
            let sizeInKB = Double(size) / 1024.0
            return String(format: "%.1f kb", sizeInKB)
        }
    }

    private func prettyDate(
        for date: Date?
    ) -> String {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = "dd/MM/yy"

        return dateFormatter.string(from: date ?? Date(timeIntervalSince1970: 0))
    }
}
