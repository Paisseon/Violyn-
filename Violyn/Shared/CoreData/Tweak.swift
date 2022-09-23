//
//  Tweak.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import CoreData

// Generate a fetch request for all tweaks, sorted alphabetically

extension Tweak {
    public class func genFetchRequest() -> NSFetchRequest<Tweak> {
        let fetchRequest = NSFetchRequest<Tweak>(entityName: String(describing: Tweak.self))
        let sortDescript = NSSortDescriptor(keyPath: \Tweak.name, ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescript]
        
        return fetchRequest
    }
    
    public class func genSingleFetchRequest(for name: String) -> NSFetchRequest<Tweak> {
        let fetchRequest = NSFetchRequest<Tweak>(entityName: String(describing: Tweak.self))
        let predicate    = NSPredicate(format: "name LIKE %@", name)
        
        fetchRequest.predicate = predicate
        
        return fetchRequest
    }
}
