//
//  UploadResult.swift
//  Violyn
//
//  Created by Lilliana on 27/11/2022.
//

enum UploadResult {
    case alreadyUploaded
    case login
    case notFound
    case sizeMismatch
    case success
    case upload
    case url
    
    var description: String {
        switch self {
            case .alreadyUploaded:
                return "The tweak already exists on CyDown"
            case .login:
                return "Authentication failed"
            case .notFound:
                return "Couldn't find your file"
            case .sizeMismatch:
                return "Uploaded file size doesn't match real file size"
            case .success:
                return "Success!"
            case .upload:
                return "Couldn't finish uploading the file"
            case .url:
                return "Couldn't get a destination URL"
        }
    }
}
