//
//  Searcher.swift
//  Violyn
//
//  Created by Lilliana on 29/11/2022.
//

import CoreData
import Foundation

struct Searcher {
    // MARK: Internal

    static func load(
        _ size: LoadSize
    ) async throws {
        let parent: NSManagedObjectContext = DataManager.container.viewContext
        let context: NSManagedObjectContext = .init(concurrencyType: .privateQueueConcurrencyType)
        let maxPages: Int = (size != .update) ? try await maxPages() : 0
        var pages: Int = 0
        
        context.parent = parent
        
        switch size {
            case .update:
                pages = 1
            case .quarter:
                pages = maxPages / 4
            case .half:
                pages = maxPages / 2
            case .three:
                pages = (maxPages / 4) * 3
            case .full:
                pages = maxPages
        }
        
        await Progress.shared.addTasks(Double(pages))
        
        // Page order doesn't matter, so this is more efficient
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for i in 1 ... pages {
                group.addTask {
                    let tmpFiles: [(String, Int64, Date)] = try await files(from: page(i))
                    
                    tmpFiles.forEach { file in
                        context.performAndWait {
                            let object: Entity = .init(context: context)
                            object.name = file.0
                            object.size = file.1
                            object.date = file.2
                        }
                    }
                    
                    await Progress.shared.finishTask()
                }
            }
        }
        
        await DataManager.save(context)
    }

    // MARK: Private

    private static func files(
        from page: String
    ) async throws -> [(String, Int64, Date)] {
        var ret: [(String, Int64, Date)] = []
        
        // Find the file names, sizes, and upload dates
        
        let regex0: NSRegularExpression = try .init(pattern: #"(?<=.deb\" title=\")(.*)(?=_iphoneos-arm)"#)
        let matches0: [NSTextCheckingResult] = regex0.matches(in: page, range: NSRange(page.startIndex..., in: page))
        
        let regex1: NSRegularExpression = try .init(pattern: #"\d{1,3},?\d?\s(MB|KB)"#)
        let matches1: [NSTextCheckingResult] = regex1.matches(in: page, range: NSRange(page.startIndex..., in: page))
        
        let regex2: NSRegularExpression = try .init(pattern: #"\d{1,2} [acegijklmprstuwyzź]{3} \d{2} \d{1,2}:\d{1,2}"#)
        let matches2: [NSTextCheckingResult] = regex2.matches(in: page, range: NSRange(page.startIndex..., in: page))
        
        // Create a String array from the file names
        
        let fileNames: [String] = matches0.map {
            String(page[Range($0.range, in: page)!])
        }
        
        // Convert the file sizes into an array of Int64 representing the sizes in bytes
        
        let fileSizes: [Int64] = matches1.map {
            size(from: String(page[Range($0.range, in: page)!]).replacingOccurrences(of: ",", with: "."))
        }
        
        // Convert the upload dates into an array of dates
        
        let fileDates: [Date] = matches2.map {
            date(from: String(page[Range($0.range, in: page)!]))
        }
        
        // Each page should contain 30 files, but apparently not all of them can be detected
        
        let cap: Int = min(fileNames.count, fileSizes.count, fileDates.count) - 1
    
        for i in 0 ... cap {
            ret.append((fileNames[i], fileSizes[i], fileDates[i]))
        }
        
        return ret
    }

    private static func page(
        _ number: Int
    ) async throws -> String {
        let url: URL = .init(string: ChomikAPI.search.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=farato&FolderId=4&PageNr=\(number)\(RequestHelper.token)".data(using: .utf8)
        
        RequestHelper.headers(
            from: [
                "Connection": "close",
                "Referer": ChomikAPI.files.rawValue
            ],
            for: &request
        )
        
        return try await RequestHelper.string(from: request)
    }

    private static func maxPages() async throws -> Int {
        let url: URL = .init(string: ChomikAPI.search.rawValue)!
        var request: URLRequest = .init(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = "ChomikName=farato&FolderId=4&PageNr=999\(RequestHelper.token)".data(using: .utf8)
        
        RequestHelper.headers(
            from: [
                "Connection": "close",
                "Referer": ChomikAPI.files.rawValue
            ],
            for: &request
        )
        
        let results: String = try await RequestHelper.string(from: request)
        
        guard let range: Range<String.Index> = results.range(of: #"(?<=(value=\"))\d{3}(?=\")"#, options: .regularExpression) else {
            return 600
        }
        
        return Int(results[range]) ?? 600
    }
    
    private static func size(
        from sizeString: String
    ) -> Int64 {
        let sizeComponents: [String] = sizeString.components(separatedBy: " ")
        let sizeInBytes: Double = .init(sizeComponents[0]) ?? 0
        
        if sizeComponents[1] == "MB" {
            return Int64(sizeInBytes * 1024 * 1024)
        } else if sizeComponents[1] == "KB" {
            return Int64(sizeInBytes * 1024)
        }
        
        return Int64(sizeInBytes)
    }
    
    private static func date(
        from dateString: String
    ) -> Date {
        let formatter: DateFormatter = .init()
        
        formatter.dateFormat = "dd MMM yy HH:mm"
        formatter.locale = .init(identifier: "pl_PL")
        
        return formatter.date(from: dateString) ?? Date(timeIntervalSince1970: 0)
    }
}
