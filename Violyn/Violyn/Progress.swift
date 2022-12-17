//
//  Progress.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

import Combine
import Dispatch

#if os(macOS)
import AppKit
import UniformTypeIdentifiers
#endif

// MARK: - Progress

@MainActor
final class Progress: ObservableObject {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared: Progress = .init()

    @Published private(set) var current: Double = 0.0
    @Published private(set) var didReload: Bool = false
    @Published private(set) var finished: Double = 0.0
    @Published private(set) var label: String? = nil

    func addTasks(
        _ count: Double
    ) async {
        if count > 0 {
            current += count
        }
    }
    
    func cancelTasks(
        _ count: Double
    ) async {
        if count < current {
            current -= count
        } else {
            current = 0
        }
    }
    
    func clear() async {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.current = 0.0
            self.finished = 0.0
            self.label = nil
        }
    }
    
    func finishTask() async {
        finished += 1
    }
    
    func setDidReload(
        _ state: Bool
    ) async {
        didReload = state
    }
    
    func setLabel(
        _ text: String?
    ) async {
        label = text
    }

    #if os(macOS)
    func showSavePanel(
        _ fileURL: URL,
        _ appendix: String
    ) async {
        let savePanel: NSSavePanel = .init()
        
        savePanel.allowedContentTypes = [UTType(filenameExtension: "deb")!]
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.nameFieldStringValue = appendix
        savePanel.title = "Save the deb?"
        savePanel.message = "Choose a location to save"
        
        let response: NSApplication.ModalResponse = savePanel.runModal()
        let url: URL? = response == .OK ? savePanel.url : nil
        
        if let url {
            Task {
                do {
                    try await FileHelper.move(from: fileURL, to: url)
                } catch {
                    label = error.localizedDescription
                    await clear()
                }
            }
        }
    }
    #endif
}
