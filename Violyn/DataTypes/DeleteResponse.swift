//
//  DeleteResponse.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

import Foundation

struct DeleteResponse: Decodable {
    let data: [String: String]
    let isSuccess: Bool
    let trackingCodeJS: String?
    let type: String
    let content: String
    let title: String
    let refreshTopBar: Bool
    let containsCaptcha: Bool
    
    enum CodingKeys: String, CodingKey {
        case refreshTopBar, trackingCodeJS
        case data = "Data"
        case isSuccess = "IsSuccess"
        case type = "Type"
        case content = "Content"
        case title = "Title"
        case containsCaptcha = "ContainsCaptcha"
    }
}
