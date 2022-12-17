//
//  SearchView.swift
//  Violyn
//
//  Created by Lilliana on 01/12/2022.
//

import CoreData
import SwiftUI

struct SearchView: View {
    // MARK: Internal

    @FetchRequest(entity: .entity(forEntityName: "Entity", in: DataManager.container.viewContext)!, sortDescriptors: [.init(keyPath: \Entity.date, ascending: false)]) var entities: FetchedResults<Entity>

    var body: some View {
        if !entities.isEmpty {
            VStack {
                TextField("Search", text: $observer.searchText)
                    .padding()
                
                if observer.debouncedText.isEmpty {
                    List(entities[newestAnchor ... oldestAnchor]) {
                        InfoView(entity: $0)
                        #if os(macOS)
                        Divider()
                        #endif
                    }
                } else {
                    List(
                        entities.filter {
                            $0.name?.lowercased().contains(observer.debouncedText.lowercased()) == true
                        }
                    ) {
                        InfoView(entity: $0)
                        #if os(macOS)
                        Divider()
                        #endif
                    }
                }
                
                HStack {
                    Button(action: {
                        if newestAnchor > 0, oldestAnchor > 29 {
                            newestAnchor -= 30
                            oldestAnchor -= 30
                        }
                    }) {
                        Image(systemName: "play")
                            .rotationEffect(.degrees(180))
                    }
                    .disabled(!observer.debouncedText.isEmpty)
                    
                    Spacer()
                    
                    Button(action: {
                        if oldestAnchor < entities.count - 30 {
                            newestAnchor += 30
                            oldestAnchor += 30
                        }
                    }) {
                        Image(systemName: "play")
                    }
                    .disabled(!observer.debouncedText.isEmpty)
                }
                .padding()
            }
            .padding()
            .onAppear {
                let reloadDate: Date = .init(timeIntervalSince1970: UserDefaults.standard.double(forKey: "ReloadDate"))
                if !progress.didReload, reloadDate.distance(to: Date()) >= 0x15180 {
                    Task {
                        do {
                            try await Searcher.load(.update)
                            await progress.setDidReload(true)
                        } catch {
                            await Progress.shared.setLabel(error.localizedDescription)
                            await Progress.shared.clear()
                        }
                        
                        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "ReloadDate")
                    }
                }
            }
        } else {
            VStack {
                Picker("", selection: $selectedSize) {
                    ForEach(loadSizes, id: \.self) { size in
                        Text(size.description)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                TaskButtonView(title: "Load", icon: "square.and.arrow.down") {
                    Task {
                        do {
                            try await Searcher.load(selectedSize)
                            
                            if progress.finished >= progress.current {
                                await Progress.shared.clear()
                            }
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

    @StateObject private var observer: TextFieldObserver = .init(delay: .seconds(0.25))
    @StateObject private var progress: Progress = .shared
    
    @State private var selectedSize: LoadSize = .quarter
    @State private var newestAnchor: Int = 0
    @State private var oldestAnchor: Int = 29
    
    private let loadSizes: [LoadSize] = [.quarter, .half, .three, .full]
}
