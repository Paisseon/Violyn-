//
//  Search.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import CoreData
import SwiftUI

extension ViolynController {
    
    // Get the full contents of a page
    
    public func getPage(_ number: Int) -> String {
        let url       = URL(string: "https://chomikuj.pl/action/Files/FilesList")!
        var r1        = URLRequest(url: url)
        
        r1.httpMethod = "POST"
        r1.httpBody   = "ChomikName=farato&FolderId=4&PageNr=\(number)\(token)".data(using: .utf8)
        
        genHeaders(from: ["X-Requested-With" : "XMLHttpRequest",
                          "Cookie"           : cookie,
                          "Connection"       : "close",
                          "Referer"          : "https://chomikuj.pl/farato/Dokumenty/debfiles"],
                   for: &r1)
        
        return sendRequest(r1, "Failed to search")["data"] as! String
    }
    
    // Get list of files on a page
    
    public func listFiles(from page: String) -> [String] {
        do {
            let regex   = try NSRegularExpression(pattern: "(?<=.deb\" title=\")(.*)(?=_iphoneos-arm)")
            let results = regex.matches(in: page, range: NSRange(page.startIndex..., in: page))
            
            return results.map {
                String(page[Range($0.range, in: page)!])
            }
        } catch {
            self.error = "Error getting file list from page"
        }
        
        return ["com.example.tweak_v\(page)"]
    }
    
    // Get the page number for the end page
    
    public func getMaxPages() -> Int {
        let url       = URL(string: "https://chomikuj.pl/action/Files/FilesList")!
        var r1        = URLRequest(url: url)
        
        r1.httpMethod = "POST"
        r1.httpBody   = "ChomikName=farato&FolderId=4&PageNr=999\(token)".data(using: .utf8)
        
        genHeaders(from: ["X-Requested-With" : "XMLHttpRequest",
                          "Cookie"           : cookie,
                          "Connection"       : "close",
                          "Referer"          : "https://chomikuj.pl/farato/Dokumenty/debfiles"],
                   for: &r1)
        
        let results = sendRequest(r1, "Failed to count page number")["data"] as! String
        
        guard let r1Range: Range<String.Index> = results.range(of: #"(?<=(value=\"))\d{3}(?=\")"#, options: .regularExpression) else {
            return 721
        }
            
        return Int(results[r1Range]) ?? 721
    }
    
    // Create a CoreData object for every file in the CyDown database
    
    public func loadFiles(ofSize size: LoadSize) {
        DispatchQueue(label: "ViolynQueue").async { [self] in
            let parent     = DataController.shared.persistentContainer.viewContext
            let context    = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            let maxPages   = (size != .update && size != .tiny) ? getMaxPages() : 0
            var pages      = 0
            
            context.parent = parent
            
            switch size {
                case .update:
                    pages = 1
                case .tiny:
                    pages = 50
                case .smol:
                    pages = maxPages / 4
                case .medium:
                    pages = maxPages / 2
                case .large:
                    pages = (maxPages / 4) * 3
                case .full:
                    pages = maxPages
            }
            
            reset()
            
            /// Loop through the pages and create a CoreData object for each file therein
            
            for i in 1...pages {
                for file in listFiles(from: getPage(i)) {
                    context.performAndWait {
                        let object  = Tweak(context: context)
                        object.name = file
                    }
                }
                
                incrementProgress(of: Double(pages))
            }
            DataController.shared.saveContext(privateContext: context)
            succeed()
        }
    }
}
