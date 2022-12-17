//
//  Downloader.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

import Combine
import Foundation

struct Downloader {
    private static func _download(
        from redirectURL: URL
    ) async throws -> URL {
        if #available(iOS 15, macOS 12, *) {
            return try await URLSession.shared.download(from: redirectURL).0
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let dlTask: URLSessionDownloadTask = URLSession.shared.downloadTask(with: URLRequest(url: redirectURL)) { url, response, error in
                if let url {
                    let localURL: URL = .init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!).appendingPathComponent(UUID().uuidString)
                    
                    do {
                        try FileManager.default.moveItem(at: url, to: localURL)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                    continuation.resume(returning: localURL)
                }
                
                if let error {
                    continuation.resume(throwing: error)
                }
            }
            
            dlTask.resume()
        }
    }
    
    @discardableResult
    static func download(
        _ package: String,
        _ version: String
    ) async throws -> DownloadResult {
        let progress: Progress = .shared
        await progress.addTasks(4)
        
        let id: Int64 = await fileID(package, version)
        
        guard id != 404 else {
            await progress.cancelTasks(4)
            return .notFound
        }
        
        guard id != 0 else {
            await progress.cancelTasks(4)
            return .noFileID
        }
        
        await progress.finishTask()
        
        let r2Body: Data = "fileId=\(id)\(RequestHelper.token)".data(using: .utf8)!
        let r2URL: URL = .init(string: ChomikAPI.download.rawValue)!
        var r2: URLRequest = .init(url: r2URL)
        
        r2.httpMethod = "POST"
        r2.httpBody = r2Body
        
        RequestHelper.headers(
            from: [:],
            for: &r2
        )
        
        guard let license: DownloadResponse = try await RequestHelper.send(r2) else {
            await progress.cancelTasks(3)
            return .license
        }
        
        await progress.finishTask()
        let dlURL: URL = try await _download(from: license.redirectURL)
        await progress.finishTask()
        
        if access(dlURL.path, F_OK) != 0 {
            await progress.cancelTasks(1)
            return .save
        }
        
        #if os(iOS)
        let destination: URL = .init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        try await FileHelper.move(from: dlURL, to: destination.appendingPathComponent("\(package)_\(version)_iphoneos-arm.deb"))
        
        print(destination.path)
        #else
        await Progress.shared.showSavePanel(dlURL, "\(package)_\(version)_iphoneos-arm.deb")
        #endif
        
        await progress.finishTask()
        
        return .success
    }
    
    static func fileID(
        _ package: String,
        _ version: String
    ) async -> Int64 {
        do {
            let r1URL: URL = .init(string: "\(ChomikAPI.files.rawValue)/\(package)_v\(version)_iphoneos-arm.deb")!
            let (data, response): (Data, URLResponse) = try await URLSession.shared.data14(for: URLRequest(url: r1URL))
            let contents: String = .init(decoding: data, as: UTF8.self)
            
            guard (response as? HTTPURLResponse)?.statusCode != 404 else {
                return 404
            }
            
            if let range: Range<String.Index> = contents.range(of: #"\d{10}(?=.d)"#, options: .regularExpression) {
                return Int64(contents[range].description) ?? 0
            }
        } catch {
            await Progress.shared.setLabel(error.localizedDescription)
            await Progress.shared.clear()
        }
        
        return 0
    }
}
