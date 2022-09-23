//
//  Download.swift
//  Violyn
//
//  Created by Lilliana on 15/09/2022.
//

import Foundation

extension ViolynController {
    
    // Download a deb from CyDown
    
    public func download(_ package: String, _ version: String) {
        reset()
            
        DispatchQueue.global(qos: .userInitiated).async { [self] in
            
            /// Ensure the target file exists on Chomikuj
            
            guard let r1 = try? String(contentsOf: URL(string: "https://chomikuj.pl/farato/Dokumenty/debfiles/\(package)_v\(version)_iphoneos-arm.deb")!, encoding: String.Encoding.utf8) else {
                fail(with: "\(package) (\(version)) was not found on server")
                return
            }
            
            /// Get the file ID, i.e., the first sequence of 10 numbers
                
            guard let r1Range: Range<String.Index> = r1.range(of: #"\d{10}(?=.d)"#, options: .regularExpression) else {
                fail(with: "\(package) does not have a valid FileId")
                return
            }
                
            let fileId = r1[r1Range]
            
            incrementProgress(of: 4.0)
            
            /// Connect to the license server using the file ID to get the redirect URL
                
            let r2Data = "fileId=\(fileId)\(token)".data(using: .utf8)
                
            guard let r2Url = URL(string: "https://chomikuj.pl/action/License/Download") else {
                fail(with: "Could not connect to license server")
                return
            }
                
            var r2 = URLRequest(url: r2Url)
                
            r2.httpMethod = "POST"
            r2.httpBody   = r2Data
                
            genHeaders(from: ["X-Requested-With": "XMLHttpRequest",
                              "Cookie": cookie],
                       for: &r2)
                
            let json = sendRequest(r2, "Could not connect to license server")
            
            incrementProgress(of: 4.0)
                
            guard let redirect = json["redirectUrl"] as? String else {
                fail(with: "Could not authenticate download for \(package)")
                return
            }
                
            let r3 = URL(string: redirect)!
            
            /// Download the deb file to our Documents folder, which appears in the Files/Arkiver app
                
            guard let deb = try? Data(contentsOf: r3) else {
                fail(with: "Could not complete download for \(package)")
                return
            }
            
            incrementProgress(of: 4.0)
            
            #if os(iOS)
                let docsDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            #else
                let docsDir = ("~/Downloads/" as NSString).expandingTildeInPath
            #endif
            
            let debPath = "\(docsDir)/\(package)_\(version)_iphoneos-arm.deb"
                
            do {
                try NSData(data: deb).write(toFile: debPath)
            } catch {
                fail(with: "Failed to add .deb to Files")
                return
            }
                
            succeed()
        }
    }
}
