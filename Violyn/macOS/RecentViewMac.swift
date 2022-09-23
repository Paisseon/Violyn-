//
//  RecentViewMac.swift
//  Violyn (macOS)
//
//  Created by Lilliana on 15/09/2022.
//

import CoreData
import SwiftUI

struct RecentViewMac: View {
    @Environment(\.managedObjectContext) var moc
    
    @StateObject var vc  = ViolynController.shared
    
    var body: some View {
        
        /// If the file list has already been loaded, update and show the search bar
        
        VStack {
            if !vc.reloaded {
                Text("File list is updating, please wait warmly...")
                ProgressView()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(vc.recent, id: \.self) { file in
                            HStack {
                                Text(file)
                                    .frame(height: 50, alignment: .center)
                                    .frame(maxWidth: .infinity)
                                    .contentShape(Rectangle())
                                
                                Button {
                                    vc.download(file.components(separatedBy: "_v")[0], file.components(separatedBy: "_v")[1])
                                } label: {
                                    Image(systemName: "square.and.arrow.down")
                                        .foregroundColor(.white)
                                }
                                    .disabled(vc.isHolding)
                                    .background(Color.blue)
                            }
                        }
                    }
                }
                .padding([.top, .bottom])
                .padding([.top, .bottom])
            }
        }
        .onAppear {
            if !vc.reloaded {
                
                /// Get the most recent page and loop through it to see if there are any new files. If so, add them to the CoreData stack
                
                DispatchQueue(label: "ViolynQueue").async {
                    let context    = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                    context.parent = moc
                    var reloaded   = false
                    
                    let newPage = vc.listFiles(from: vc.getPage(1))
                    
                    for pageItem in newPage {
                        let package = pageItem.components(separatedBy: "_v")[0]
                        let version = pageItem.components(separatedBy: "_v")[1]
                        var fetched = [Tweak]()
                        
                        do {
                            fetched = try context.fetch(Tweak.genSingleFetchRequest(for: "\(package)_v\(version)"))
                        } catch {
                            reloaded = true
                        }
                        
                        if reloaded || fetched.count > 0 {
                            reloaded = true
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
    }
}
