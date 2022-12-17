//
//  DataManager.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

import CoreData

actor DataManager {
    static let container: NSPersistentContainer = {
        let pContainer: NSPersistentContainer = .init(name: "Model")

        pContainer.loadPersistentStores { _, _ in
            pContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        }

        return pContainer
    }()

    static func save(
        _ pContext: NSManagedObjectContext? = nil
    ) async {
        do {
            if let pContext {
                pContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
                try pContext.save()
            }
            
            let context: NSManagedObjectContext = container.viewContext

            if context.hasChanges {
                try context.save()
            }
        } catch {
            await Progress.shared.setLabel(error.localizedDescription)
            await Progress.shared.clear()
        }
    }

    static func wipe() async {
        let context: NSManagedObjectContext = container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = .init(entityName: "Entity")
        let deleteRequest: NSBatchDeleteRequest = .init(fetchRequest: fetchRequest)

        do {
            try context.execute(deleteRequest)
        } catch {
            await Progress.shared.setLabel(error.localizedDescription)
            await Progress.shared.clear()
        }
    }
}
