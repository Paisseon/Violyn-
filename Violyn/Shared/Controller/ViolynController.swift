//
//  ViolynController.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import Foundation

final class ViolynController: ObservableObject {
    static let shared = ViolynController()
    
    public let token  = "&__RequestVerificationToken=b%2BsiLdIH65m5AVq2Xk7B0VHudOFB%2BrddgeMKqSSaYhNNEHULqRRQbNWkLDrPB%2FT%2F2aCx0RIJUz3w5UVygR6StTykyxlNxGWo3iWYC5eIjljDNHYcM5AL9MbQagSUy6YKs%2BkyXg%3D%3D"
    public let cookie = "ChomikSession=d3fb23c6-430d-456c-b729-bbb72fefaf99; __RequestVerificationToken_Lw__=w8xQ4U9IcdB71uD/zSxUsJXuEQQOsI1Dogfg9d4xN3p0xxRp/wTg+oqiDdqIYGZfhEfswCKnlA47H0IBDt53LrdOy7oCNzKdOdp/lTwQAn/Zw++5skZFvLLcktKreTD7mZMZTQ==; rcid=3; guid=999f1623-f0ea-4497-8775-50832b6258df;"
    
    // Status for SwiftUI to track
    
    @Published var error     = ""
    @Published var isSuccess = false
    @Published var isHolding = false
    @Published var progress  = 0.0
    @Published var recent    = [String]()
    @Published var reloaded  = false
    
    public init() {}
    
    // Useful functions to handle status
    
    public func fail(with err0r: String) {
        DispatchQueue.main.async { [self] in
            error     = err0r
            isHolding = false
            isSuccess = false
            progress  = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.error = ""
        })
    }
    
    public func reset() {
        DispatchQueue.main.async { [self] in
            error     = ""
            isHolding = true
            isSuccess = false
            progress  = 0.0
        }
    }
    
    public func succeed() {
        DispatchQueue.main.async { [self] in
            error     = ""
            isHolding = false
            isSuccess = true
            progress  = 1.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.isSuccess = false
        })
    }
    
    public func incrementProgress(of ratio: Double) {
        DispatchQueue.main.async {
            self.progress += 1.0 / ratio
        }
    }
    
    // Send a request to Chomikuj and return JSON data as an NSDictionary
    
    public func sendRequest(_ request: URLRequest, _ err: String) -> NSDictionary {
        var retData   = Data()
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                retData = data
            }
            
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        
        guard let json: NSDictionary = (try? JSONSerialization.jsonObject(with: retData, options: [])) as? NSDictionary else {
                    return ["data": String(decoding: retData, as: UTF8.self)] as [String: String] as NSDictionary
        }
        
        return json
    }
    
    // Get the file id for a deb
    
    func getFileId(_ package: String, _ version: String) -> String {
        let url = URL(string: "https://chomikuj.pl/farato/Dokumenty/debfiles/\(package)_v\(version)_iphoneos-arm.deb")!
        
        guard let r1 = try? String(contentsOf: url, encoding: String.Encoding.utf8) else {
            error = "getFileId returned nil for \(package) \(version)"
            return "0000000000"
        }
        
        if let range: Range<String.Index> = r1.range(of: #"\d{10}(?=.d)"#, options: .regularExpression) {
            return String(r1[range])
        }
        
        return "0000000000"
    }
    
    // Generate HTTP headers
    
    func genHeaders(from headers: [String: String], for request: inout URLRequest) {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
