//
//  SearchViewiOS.swift
//  Violyn (iOS)
//
//  Created by Lilliana on 15/09/2022.
//

import CoreData
import SwiftUI
import SwipeActions

struct SearchViewiOS: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(fetchRequest: Tweak.genFetchRequest(), animation: .easeIn) var files: FetchedResults<Tweak>
    
    @StateObject var vc  = ViolynController.shared
    
    @State private var search    = ""
    @State private var showAlert = false
    
    var body: some View {
        
        /// If the file list has already been loaded, update and show the search bar
        
        if files.count > 0 {
            VStack {
                if vc.reloaded {
                    TextField("Search", text: $search)
                        .modifier(LiteralEntry())
                        .padding()
                } else {
                    Text("File list is updating, please wait warmly...")
                    ProgressView()
                }
                
                /// If the search bar has text in it, list all files with the search parameters in the name
                
                if search.count > 0 {
                    ScrollView {
                        LazyVStack {
                            ForEach(files, id: \.self) { file in
                                if file.name!.lowercased().contains(search.lowercased()) {
                                    HStack {
                                        Text(file.name!)
                                            .frame(height: 50, alignment: .center)
                                            .frame(maxWidth: .infinity)
                                            .contentShape(Rectangle())
                                            .addSwipeAction(menu: .slided, edge: .trailing) {
                                                Button(action: {
                                                    vc.download(file.name!.components(separatedBy: "_v")[0], file.name!.components(separatedBy: "_v")[1])
                                                }) {
                                                    Image(systemName: "square.and.arrow.down")
                                                        .foregroundColor(.white)
                                                }
                                                    .disabled(vc.isHolding)
                                                    .frame(width: 60, height: 50, alignment: .center)
                                                    .background(Color.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                if !vc.reloaded {
                    
                    /// Get the most recent page and loop through it to see if there are any new files. If so, add them to the CoreData stack
                    
                    DispatchQueue(label: "ViolynQueue").async {
                        let context    = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                        context.parent = moc
                        
                        let newPage = vc.listFiles(from: vc.getPage(1))
                        
                        for pageItem in newPage {
                            let package = pageItem.components(separatedBy: "_v")[0]
                            let version = pageItem.components(separatedBy: "_v")[1]
                            var fetched = [Tweak]()
                            
                            do {
                                fetched = try context.fetch(Tweak.genSingleFetchRequest(for: "\(package)_v\(version)"))
                            } catch {
                                vc.reloaded = true
                            }
                            
                            if vc.reloaded || fetched.count > 0 {
                                DispatchQueue.main.async {
                                    vc.reloaded = true
                                }
                                
                                break
                            }
                            
                            let newFile  = Tweak(context: context)
                            newFile.name = pageItem

                            DataController.shared.saveContext(privateContext: context)
                        }
                        
                        DispatchQueue.main.async {
                            vc.recent   = newPage
                            vc.reloaded = true
                        }
                    }
                }
            }
        } else {
            VStack {
                Text("Loading file list may take a while.")
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing])
                
                Button(action: {
                    if vc.isHolding {
                        return
                    }
                    
                    showAlert = true
                }, label: {
                    if vc.isHolding {
                        ProgressView()
                    } else {
                        if vc.isSuccess {
                            Text("Success!")
                        } else {
                            Text(vc.error != "" ? vc.error : "Load Files")
                        }
                    }
                })
                    .opacity(vc.isHolding ? 0.6 : 1.0)
                    .buttonStyle(ProgressStyle())
                    .padding()
            }
            .actionSheet(isPresented: $showAlert) { ActionSheet(
                               title: Text("Load Size"),
                             message: Text("Smaller sizes load faster, but have fewer results"),
                             buttons: [
                                            Alert.Button.default(Text("Tiny")) {
                                                vc.loadFiles(ofSize: .tiny)
                                            },
                                            
                                            Alert.Button.default(Text("Smol")) {
                                                vc.loadFiles(ofSize: .smol)
                                            },
                                            
                                            Alert.Button.default(Text("Medium")) {
                                                vc.loadFiles(ofSize: .medium)
                                            },
                                            
                                            Alert.Button.default(Text("Large")) {
                                                vc.loadFiles(ofSize: .large)
                                            },
                                            
                                            Alert.Button.default(Text("Full")) {
                                                vc.loadFiles(ofSize: .full)
                                            }
                                        ])}
        }
    }
}
