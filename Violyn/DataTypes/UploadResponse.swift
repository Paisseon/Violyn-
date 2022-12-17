//
//  UploadResponse.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

struct UploadResponse: Codable {
    let size: UInt64
    let id: Int
    let fileID: Int
    let folderName: String
    let name: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case fileID = "fileId"
        case size, id, folderName, name, url
    }
}
