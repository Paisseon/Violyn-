//
//  ChomikURLResponse.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

import Foundation

struct ChomikURLResponse: Decodable {
    let url: URL
    let chomikID: Int
    let folderID: Int
    let anonymousUpload: Bool
    
    enum CodingKeys: String, CodingKey {
        case url = "Url"
        case chomikID = "ChomikId"
        case folderID = "FolderId"
        case anonymousUpload = "AnonymousUpload"
    }
}
