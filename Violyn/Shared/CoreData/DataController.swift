//
//  DataController.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import CoreData

class DataController {
    static let shared = DataController()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ViolynModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                ViolynController.shared.error = error.localizedDescription
            }
            
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        }
        
        return container
    }()
    
    private init() {}
    
    public func saveContext(privateContext: NSManagedObjectContext? = nil) {
        if privateContext != nil {
            if let privateContext = privateContext {
                do {
                    try privateContext.save()
                } catch let error {
                    ViolynController.shared.error = error.localizedDescription
                }
            }
        }
        
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                ViolynController.shared.error = error.localizedDescription
            }
        }
    }
}
